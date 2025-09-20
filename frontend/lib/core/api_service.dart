import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiService {
  final String baseUrl;
  ApiService({this.baseUrl = AppConstants.baseUrl});

  Future<Map<String, dynamic>> login(String username, String role) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'role': role}));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Login failed: ${res.body}');
  }

  Future<Map<String, dynamic>> createRequest(String userId, List<String> items) async {
    final res = await http.post(Uri.parse('$baseUrl/requests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'items': items}));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Create request failed: ${res.body}');
  }

  Future<List<dynamic>> fetchRequests({required String role, String? userId}) async {
    final uri = Uri.parse('$baseUrl/requests').replace(queryParameters: {
      if (role.isNotEmpty) 'role': role,
      if (userId != null) 'userId': userId,
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Fetch requests failed: ${res.body}');
  }

  Future<Map<String, dynamic>> confirmRequest(String requestId, List<Map<String, dynamic>> confirmations, String receiverId) async {
    final res = await http.patch(Uri.parse('$baseUrl/requests/$requestId/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'confirmations': confirmations, 'receiverId': receiverId}));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Confirm failed: ${res.body}');
  }
}

