// lib/providers/request_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../core/socket_service.dart';
import '../models/request.dart';

class RequestState {
  final List<RequestModel> requests;
  final bool loading;
  final String? error;

  const RequestState(
      {this.requests = const [], this.loading = false, this.error});

  RequestState copyWith(
      {List<RequestModel>? requests, bool? loading, String? error}) {
    return RequestState(
      requests: requests ?? this.requests,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class RequestNotifier extends StateNotifier<RequestState> {
  final ApiService _api;
  final SocketService _socket;
  Timer? _poller;
  bool _isFetching = false;

  RequestNotifier({ApiService? api, SocketService? socket})
      : _api = api ?? ApiService(),
        _socket = socket ?? SocketService(),
        super(const RequestState());

  /// Start: initial fetch, socket connect and polling fallback
  Future<void> start({required String role, String? userId}) async {
    debugPrint('[REQUEST_PROVIDER] start(role=$role, userId=$userId)');
    await fetch(role: role, userId: userId);

    // Connect socket with safe wrappers so exceptions don't bubble to UI
    try {
      _socket.connect(
        onRequestCreated: (data) {
          try {
            debugPrint('[REQUEST_PROVIDER] socket:onRequestCreated -> $data');
            final newReq =
                RequestModel.fromJson(Map<String, dynamic>.from(data));
            // Prepend and clear error / loading
            state = state.copyWith(
                requests: [newReq, ...state.requests],
                loading: false,
                error: null);
          } catch (e, st) {
            debugPrint(
                '[REQUEST_PROVIDER] socket:onRequestCreated ERROR: $e\n$st');
          }
        },
        onRequestUpdated: (data) {
          try {
            debugPrint('[REQUEST_PROVIDER] socket:onRequestUpdated -> $data');
            final updated =
                RequestModel.fromJson(Map<String, dynamic>.from(data));
            _mergeUpdated(updated);
          } catch (e, st) {
            debugPrint(
                '[REQUEST_PROVIDER] socket:onRequestUpdated ERROR: $e\n$st');
          }
        },
        onRequestReassigned: (data) {
          try {
            debugPrint(
                '[REQUEST_PROVIDER] socket:onRequestReassigned -> $data');
            final newReq =
                RequestModel.fromJson(Map<String, dynamic>.from(data));
            state = state.copyWith(
                requests: [newReq, ...state.requests],
                loading: false,
                error: null);
          } catch (e, st) {
            debugPrint(
                '[REQUEST_PROVIDER] socket:onRequestReassigned ERROR: $e\n$st');
          }
        },
      );
    } catch (e, st) {
      debugPrint('[REQUEST_PROVIDER] socket.connect failed: $e\n$st');
    }

    // Polling fallback (every 8s)
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 8), (_) {
      // don't await directly in Timer callback — but call fetch and ignore return
      fetch(role: role, userId: userId);
    });
  }

  /// Stop socket & polling
  Future<void> stop() async {
    debugPrint('[REQUEST_PROVIDER] stop()');
    try {
      _socket.disconnect();
    } catch (e) {
      debugPrint('[REQUEST_PROVIDER] socket.disconnect error: $e');
    }
    _poller?.cancel();
    _poller = null;
  }

  /// Fetch requests from API (safe, guarded)
  Future<void> fetch({required String role, String? userId}) async {
    if (_isFetching) {
      debugPrint('[REQUEST_PROVIDER] fetch() blocked: already fetching');
      return;
    }
    _isFetching = true;
    state = state.copyWith(loading: true, error: null);
    try {
      final raw = await _api.fetchRequests(role: role, userId: userId);
      debugPrint('[REQUEST_PROVIDER] fetch raw response: $raw');

      final models = raw.map((m) {
        if (m is Map)
          return RequestModel.fromJson(Map<String, dynamic>.from(m));
        // try to coerce
        return RequestModel.fromJson(Map<String, dynamic>.from(m as Map));
      }).toList();

      state = state.copyWith(
          requests: models.cast<RequestModel>(), loading: false, error: null);
      debugPrint(
          '[REQUEST_PROVIDER] fetch -> loaded ${models.length} requests');
    } catch (e, st) {
      debugPrint('[REQUEST_PROVIDER] fetch ERROR: $e\n$st');
      state = state.copyWith(loading: false, error: e.toString());
    } finally {
      _isFetching = false;
    }
  }

  /// Create request
  Future<void> createRequest(String userId, List<String> items) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _api.createRequest(userId, items);
      debugPrint('[REQUEST_PROVIDER] createRequest response: $res');
      final model = RequestModel.fromJson(Map<String, dynamic>.from(res));
      state = state.copyWith(
          requests: [model, ...state.requests], loading: false, error: null);
    } catch (e, st) {
      debugPrint('[REQUEST_PROVIDER] createRequest ERROR: $e\n$st');
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Confirm request (safe parsing for either {request,reassignedRequest} or a single object)
  Future<void> confirmRequest(String requestId,
      List<Map<String, dynamic>> confirmations, String receiverId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res =
          await _api.confirmRequest(requestId, confirmations, receiverId);
      debugPrint('[REQUEST_PROVIDER] confirmRequest response: $res');

      Map<String, dynamic>? requestMap;
      Map<String, dynamic>? reassignedMap;

      if (res.containsKey('request'))
        requestMap = Map<String, dynamic>.from(res['request']);
      else if (res.containsKey('id'))
        requestMap = Map<String, dynamic>.from(res);
      if (res.containsKey('reassignedRequest'))
        reassignedMap = Map<String, dynamic>.from(res['reassignedRequest']);

      if (requestMap != null) {
        final updated = RequestModel.fromJson(requestMap);
        _mergeUpdated(updated);
      }

      if (reassignedMap != null) {
        final reassigned = RequestModel.fromJson(reassignedMap);
        state = state.copyWith(
            requests: [reassigned, ...state.requests],
            loading: false,
            error: null);
      } else {
        state = state.copyWith(loading: false, error: null);
      }
    } catch (e, st) {
      debugPrint('[REQUEST_PROVIDER] confirmRequest ERROR: $e\n$st');
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Merge updated request into current list or insert at top
  void _mergeUpdated(RequestModel updated) {
    try {
      final list = [...state.requests];
      final idx = list.indexWhere((r) => r.id == updated.id);
      if (idx >= 0) {
        list[idx] = updated;
      } else {
        list.insert(0, updated);
      }
      state = state.copyWith(requests: list, loading: false, error: null);
      debugPrint(
          '[REQUEST_PROVIDER] _mergeUpdated -> updated id=${updated.id}');
    } catch (e, st) {
      debugPrint('[REQUEST_PROVIDER] _mergeUpdated ERROR: $e\n$st');
    }
  }
}

final requestProvider = StateNotifierProvider<RequestNotifier, RequestState>(
    (ref) => RequestNotifier());
