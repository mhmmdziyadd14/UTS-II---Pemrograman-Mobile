class User {
  final int? id;
  final String username;
  final String role;

  User({this.id, required this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    // Accept id as int or numeric string
    final rawId = json['id'];
    int? parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId);
    }

    return User(
      id: parsedId,
      username: json['username'] ?? json['name'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
    };
  }
}
