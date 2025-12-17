import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ruangan_model.dart';

class RuanganService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  Future<List<RuanganItem>> fetchRuangan() async {
    final res = await http.get(Uri.parse('$baseUrl/api/ruangan'));

    if (res.statusCode != 200) {
      String message = 'Gagal memuat ruangan (HTTP ${res.statusCode})';
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

    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => RuanganItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}