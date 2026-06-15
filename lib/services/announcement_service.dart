import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/announcement_model.dart';

class AnnouncementService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  Future<List<AnnouncementItem>> fetchAnnouncements() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/announcements'));

      if (res.statusCode != 200) {
        throw Exception('Gagal memuat pengumuman');
      }

      final List data = jsonDecode(res.body);
      return data.map((e) => AnnouncementItem.fromJson(e)).toList();
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
