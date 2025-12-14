import 'package:intl/intl.dart';

class AgendaItem {
  final int id;
  final String title;
  final String subtitle;
  final DateTime datetime;
  final String tag;

  AgendaItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.datetime,
    required this.tag,
  });

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      id: json['id'] is int ? json['id'] : 0,
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      datetime:
          DateTime.tryParse(json['date_iso'].toString()) ?? DateTime.now(),
      tag: (json['location'] ?? '').toString(),
    );
  }

  // Helper untuk format tanggal sesuai request: "Ahad, 12 Januari 2025"
  String get formattedDate {
    // Membutuhkan: import 'package:intl/date_symbol_data_local.dart'; di main
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(datetime);
    } catch (e) {
      return DateFormat('yyyy-MM-dd').format(datetime);
    }
  }

  // Helper untuk jam: "19.30 WIB"
  String get formattedTime {
    try {
      return '${DateFormat('HH.mm').format(datetime)} WIB';
    } catch (e) {
      return '';
    }
  }
}
