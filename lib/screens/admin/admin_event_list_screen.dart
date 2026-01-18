class ReligiousEvent {
  final dynamic id; // Ubah ke dynamic agar bisa terima int atau String
  final String title;
  final String date;
  final String location;
  final String description;

  ReligiousEvent({
    this.id,
    required this.title,
    required this.date,
    required this.location,
    this.description = "",
  });

  factory ReligiousEvent.fromJson(Map<String, dynamic> json) {
    return ReligiousEvent(
      id: json['id'], // Terima apa adanya (int/string)
      title: json['title'],
      date: json['date'],
      location: json['location'],
      description: json['description'] ?? "",
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