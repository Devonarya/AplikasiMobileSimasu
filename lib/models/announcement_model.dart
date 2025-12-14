class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String tag;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      tag: json['tag'],
    );
  }
}
