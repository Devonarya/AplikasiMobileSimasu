class AnnouncementItem {
  final int id;
  final String title;
  final String subtitle;
  final String tag;

  AnnouncementItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: json['id'] is int ? json['id'] : 0,
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      tag: (json['tag'] ?? 'Info').toString(),
    );
  }
}
