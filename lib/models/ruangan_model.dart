class RuanganItem {
  final int id;
  final String name;
  final String? description;
  final int capacity;
  final String? facilities;
  final bool isAvailable;

  RuanganItem({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.facilities,
    required this.isAvailable,
  });

  factory RuanganItem.fromJson(Map<String, dynamic> json) {
    return RuanganItem(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      facilities: json['facilities']?.toString(),
      isAvailable: (json['is_available'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'facilities': facilities,
      'is_available': isAvailable,
    };
  }
}