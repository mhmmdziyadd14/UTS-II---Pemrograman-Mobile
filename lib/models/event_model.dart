class ReligiousEvent {
  final int? id;
  final String title;
  final String date;
  final String location;
  final String? description;

  ReligiousEvent({
    this.id,
    required this.title,
    required this.date,
    required this.location,
    this.description,
  });

  factory ReligiousEvent.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int? parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId);
    }

    return ReligiousEvent(
      id: parsedId,
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? json['desc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'description': description,
    };
  }
}