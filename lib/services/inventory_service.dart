import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/inventory_model.dart';

class InventoryService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  Future<List<InventoryItem>> fetchInventory() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/inventory'));

      if (res.statusCode != 200) {
        String message = 'Gagal memuat inventaris (HTTP ${res.statusCode})';
        try {
          final data = jsonDecode(res.body);
          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          }
        } catch (_) {}
        throw Exception(message);
      }

      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Pastikan data seluler atau WiFi Anda aktif.',
      );
    } on HttpException {
      throw Exception('Gagal menghubungi server. Coba lagi nanti.');
    } on FormatException {
      throw Exception('Terjadi kesalahan saat memproses data.');
    }
  }
}
