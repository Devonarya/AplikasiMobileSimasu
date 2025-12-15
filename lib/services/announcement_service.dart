import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/announcement_model.dart';

class AnnouncementService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  Future<List<AnnouncementItem>> fetchAnnouncements() async {
    final res = await http.get(Uri.parse('$baseUrl/api/announcements'));

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat pengumuman');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => AnnouncementItem.fromJson(e)).toList();
  }
}
