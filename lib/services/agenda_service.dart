import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/agenda_model.dart';

class AgendaService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  Future<List<AgendaItem>> fetchAgendas() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/events'));

      if (res.statusCode != 200) {
        throw Exception('Gagal memuat agenda');
      }

      final List data = jsonDecode(res.body);
      return data.map((e) => AgendaItem.fromJson(e)).toList();
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
