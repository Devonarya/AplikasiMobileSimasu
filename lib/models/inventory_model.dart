class InventoryItem {
  final int id;
  final String name;
  final String? category;
  final int stock;
  final String? description;
  final String? status;

  InventoryItem({
    required this.id,
    required this.name,
    this.category,
    required this.stock,
    this.description,
    this.status,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return InventoryItem(
      id: toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      category: json['category']?.toString(),
      stock: toInt(json['stock']),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
    );
  }

  bool get isAvailable {
    if (stock <= 0) return false;
    final s = (status ?? '').toLowerCase();
    if (s.contains('habis')) return false;
    return true;
  }
}
