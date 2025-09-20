import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';

class AuthState {
  final String? userId;
  final String? username;
  final String? role;
  final String? gender;
  final bool loading;
  final String? error;

  AuthState({
    this.userId,
    this.username,
    this.role,
    this.gender,
    this.loading = false,
    this.error,
  });

  AuthState copyWith({
    String? userId,
    String? username,
    String? role,
    String? gender,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();

  AuthNotifier() : super(AuthState());

  Future<void> login(String username, String role,
      {String gender = "male"}) async {
    state = AuthState(loading: true);
    try {
      final res = await _api.login(username, role);

      state = AuthState(
        userId: res['userId'],
        username: res['username'],
        role: res['role'],
        gender: gender,
      );
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
