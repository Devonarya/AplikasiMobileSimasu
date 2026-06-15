import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'session_manager.dart';

class ProfileService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  // Mendapatkan profile terbaru dari API
  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await SessionManager.getToken();
    if (token == null)
      throw Exception('Sesi kadaluarsa. Silakan login kembali.');

    final res = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception(_parseErrorMessage(res.body, 'Gagal memuat profil'));
    }

    final data = jsonDecode(res.body);

    // Perbarui data local setelah sukses fetch
    await SessionManager.updateLocalProfile(
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
    );
    if (data['profile_photo'] != null) {
      await SessionManager.updateLocalPhoto(data['profile_photo'].toString());
    }

    return data;
  }

  // Update Nama, Email, No HP, Alamat
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final token = await SessionManager.getToken();
    if (token == null)
      throw Exception('Sesi kadaluarsa. Silakan login kembali.');

    final res = await http.put(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(_parseErrorMessage(res.body, 'Gagal memperbarui profil'));
    }

    // Perbarui session local
    await SessionManager.updateLocalProfile(
      name: name,
      email: email,
      phone: phone,
      address: address,
    );
  }

  // Ganti Password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await SessionManager.getToken();
    if (token == null)
      throw Exception('Sesi kadaluarsa. Silakan login kembali.');

    final res = await http.put(
      Uri.parse('$baseUrl/api/profile/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(
        _parseErrorMessage(res.body, 'Gagal memperbarui password'),
      );
    }
  }

  // Upload/Update Foto Profil (Multipart)
  Future<String> uploadPhoto(File file) async {
    final token = await SessionManager.getToken();
    if (token == null)
      throw Exception('Sesi kadaluarsa. Silakan login kembali.');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/profile/photo'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    final mimeType = _detectMimeType(file.path);
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        file.path,
        contentType: mimeType,
      ),
    );

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode != 200) {
      throw Exception(
        _parseErrorMessage(res.body, 'Gagal mengunggah foto profil'),
      );
    }

    final data = jsonDecode(res.body);
    final userMap = data['user'] as Map<String, dynamic>?;
    final photoUrl = (userMap?['profile_photo'] ?? '').toString();

    if (photoUrl.isNotEmpty) {
      await SessionManager.updateLocalPhoto(photoUrl);
    }

    return photoUrl;
  }

  MediaType _detectMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (ext == 'png') return MediaType('image', 'png');
    if (ext == 'gif') return MediaType('image', 'gif');
    return MediaType('image', 'jpeg');
  }

  String _parseErrorMessage(String responseBody, String defaultMessage) {
    try {
      final data = jsonDecode(responseBody);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {
      // ignore
    }
    return defaultMessage;
  }
}
