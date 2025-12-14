import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_manager.dart';

class AuthService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      }),
    );

    if (res.statusCode == 201) return;

    String message = 'Registrasi gagal (HTTP ${res.statusCode})';
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {
      // ignore
    }
    throw Exception(message);
  }

  Future<void> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      String message = 'Login gagal (HTTP ${res.statusCode})';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {
        // ignore
      }
      throw Exception(message);
    }

    final data = jsonDecode(res.body);
    final token = (data['token'] ?? '').toString();
    final user = data['user'] as Map<String, dynamic>?;

    if (token.isEmpty || user == null) {
      throw Exception('Response login tidak valid');
    }

    final role = (user['role'] ?? 'user').toString();

    if (role == 'admin') {
      throw Exception('Login gagal.');
    }

    await SessionManager.saveSession(
      token: token,
      name: (user['name'] ?? 'User').toString(),
      email: (user['email'] ?? email).toString(),
      role: (user['role'] ?? 'user').toString(),
      phone: (user['phone'] ?? '').toString(),
    );
  }
}
