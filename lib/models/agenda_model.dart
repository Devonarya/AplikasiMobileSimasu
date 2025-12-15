import 'package:flutter/material.dart';
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
    debugPrint('AGENDA RAW JSON: $json');

    final rawDate = json['event_date'];

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(rawDate);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return AgendaItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      datetime: parsedDate.toLocal(),
      tag: json['location'] ?? '',
    );
  }

  // Helper untuk format
  String get formattedDate {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(datetime);
    } catch (e) {
      return DateFormat('yyyy-MM-dd').format(datetime);
    }
  }

  // Helper untuk jam
  String get formattedTime {
    try {
      return '${DateFormat('HH.mm').format(datetime)} WIB';
    } catch (e) {
      return '';
    }
  }
}
