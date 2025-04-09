class Lesson {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 