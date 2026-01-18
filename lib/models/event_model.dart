class ReligiousEvent {
  final dynamic id; // ID bisa string atau int
  final String title;
  final String date;
  final String location;
  final String description;
  final double? latitude;
  final double? longitude;

  ReligiousEvent({
    this.id,
    required this.title,
    required this.date,
    required this.location,
    this.description = "",
    this.latitude,
    this.longitude,
  });

  factory ReligiousEvent.fromJson(Map<String, dynamic> json) {
    return ReligiousEvent(
      id: json['id'], 
      title: json['title'],
      date: json['date'],
      location: json['location'],
      description: json['description'] ?? "",
      latitude: json['latitude'] != null ? (json['latitude'] is num ? (json['latitude'] as num).toDouble() : double.tryParse(json['latitude'].toString())) : null,
      longitude: json['longitude'] != null ? (json['longitude'] is num ? (json['longitude'] as num).toDouble() : double.tryParse(json['longitude'].toString())) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}