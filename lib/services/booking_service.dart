import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import 'session_manager.dart';

class BookingService {
  static const String baseUrl = 'https://api.indrayuda.my.id';

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd HH:mm');

  Future<List<BookingItem>> fetchBookings() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Belum login.');
    }

    final res = await http.get(
      Uri.parse('$baseUrl/api/bookings'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 401) {
      await SessionManager.clear();
      throw Exception(
        'Sesi login habis / token tidak valid. Silakan login ulang.',
      );
    }

    if (res.statusCode != 200) {
      String message = 'Gagal memuat booking (HTTP ${res.statusCode})';
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
    final items = list
        .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return _mergeInventoryDuplicates(items);
  }

  Future<void> createBooking({
    required String type,
    required int itemId,
    required String itemName,
    required DateTime start,
    required DateTime end,
    int quantity = 1,
    String? notes,
  }) async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Belum login.');
    }

    final body = {
      'type': type,
      'item_id': itemId,
      'item_name': itemName,
      'start_time': _fmt.format(start),
      'end_time': _fmt.format(end),
      'quantity': quantity,
      'notes': notes ?? '',
    };

    final res = await http.post(
      Uri.parse('$baseUrl/api/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 401) {
      await SessionManager.clear();
      throw Exception(
        'Sesi login habis / token tidak valid. Silakan login ulang.',
      );
    }

    if (res.statusCode == 201) return;

    String message = 'Booking gagal (HTTP ${res.statusCode})';
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

  List<BookingItem> _mergeInventoryDuplicates(List<BookingItem> items) {
    // Biar UI tidak “banjir” duplikat ketika booking inventory kepost berkali-kali.
    // Penggabungan hanya untuk booking inventory yang benar-benar identik.
    final Map<String, BookingItem> merged = {};

    for (final b in items) {
      if (b.type != 'inventory') {
        merged['room:${b.id}'] = b;
        continue;
      }

      final key = [
        b.userName ?? '',
        b.type,
        b.itemId.toString(),
        b.itemName,
        b.startLabel,
        b.endLabel,
        b.status,
        (b.notes ?? '').trim(),
      ].join('|');

      if (merged.containsKey(key)) {
        final existing = merged[key]!;
        merged[key] = existing.copyWith(
          quantity: existing.quantity + b.quantity,
        );
      } else {
        merged[key] = b;
      }
    }

    final result = merged.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return result;
  }
}
