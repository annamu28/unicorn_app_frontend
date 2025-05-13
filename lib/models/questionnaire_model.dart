class Questionnaire {
  final int id;
  final int lessonId;
  final String title;
  final String description;
  final List<Question> questions;
  final DateTime createdAt;

  Questionnaire({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      id: json['id'] as int,
      lessonId: json['lesson_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Question {
  final int id;
  final String text;
  final String type;
  final List<String> options;
  final bool required;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.required,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      text: json['text'] as String,
      type: json['type'] as String,
      options: (json['options'] as List).map((o) => o as String).toList(),
      required: json['required'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
      'required': required,
    };
  }
} 