class EventModel {
  final String id;
  final String title;
  final String speaker;
  final String eventDate;
  final String? eventTime;
  final String location;

  EventModel({
    required this.id,
    required this.title,
    required this.speaker,
    required this.eventDate,
    this.eventTime,
    required this.location,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'].toString(),
      title: json['title'],
      speaker: json['speaker'],
      eventDate: json['event_date'],
      eventTime: json['event_time'],
      location: json['location'],
    );
  }
}
