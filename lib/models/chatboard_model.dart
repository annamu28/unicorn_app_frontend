class ChatboardAccess {
  final List<String> squads;
  final List<String> roles;
  final List<String> countries;

  ChatboardAccess({
    required this.squads,
    required this.roles,
    required this.countries,
  });

  factory ChatboardAccess.fromJson(Map<String, dynamic> json) {
    return ChatboardAccess(
      squads: List<String>.from(json['squads'] as List),
      roles: List<String>.from(json['roles'] as List),
      countries: List<String>.from(json['countries'] as List),
    );
  }
}

class Chatboard {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final ChatboardAccess access;

  Chatboard({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.access,
  });

  factory Chatboard.fromJson(Map<String, dynamic> json) {
    return Chatboard(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      access: ChatboardAccess.fromJson(json['access'] as Map<String, dynamic>),
    );
  }
} 