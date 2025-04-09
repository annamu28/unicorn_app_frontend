class Attendance {
  final int id;
  final int lessonId;
  final int userId;
  final String status;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.lessonId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      lessonId: json['lesson_id'] as int,
      userId: json['user_id'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 