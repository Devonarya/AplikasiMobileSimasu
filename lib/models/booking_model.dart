import 'package:intl/intl.dart';

class BookingItem {
  final int id;
  final String? userName;
  final String type; // 'inventory' / 'room'
  final int itemId;
  final String itemName;
  final int quantity;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending/approved/rejected/completed
  final String? notes;

  BookingItem({
    required this.id,
    required this.userName,
    required this.type,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.notes,
  });

  static final DateFormat _apiFmt = DateFormat('yyyy-MM-dd HH:mm');

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDt(String? s) {
      if (s == null || s.trim().isEmpty) return DateTime.now();
      try {
        return _apiFmt.parse(s);
      } catch (_) {
        return DateTime.now();
      }
    }

    return BookingItem(
      id: (json['id'] as num).toInt(),
      userName: json['user_name']?.toString(),
      type: (json['type'] ?? '').toString(),
      itemId: (json['item_id'] as num).toInt(),
      itemName: (json['item_name'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      startTime: parseDt(json['start_time']?.toString()),
      endTime: parseDt(json['end_time']?.toString()),
      status: (json['status'] ?? 'pending').toString(),
      notes: json['notes']?.toString(),
    );
  }

  BookingItem copyWith({int? quantity}) {
    return BookingItem(
      id: id,
      userName: userName,
      type: type,
      itemId: itemId,
      itemName: itemName,
      quantity: quantity ?? this.quantity,
      startTime: startTime,
      endTime: endTime,
      status: status,
      notes: notes,
    );
  }

  String get startLabel => _apiFmt.format(startTime);
  String get endLabel => _apiFmt.format(endTime);

  bool isSameDay(DateTime d) {
    return startTime.year == d.year &&
        startTime.month == d.month &&
        startTime.day == d.day;
  }
}
