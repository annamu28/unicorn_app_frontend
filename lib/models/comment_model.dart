class Comment {
  final int id;
  final int postId;
  final String content;
  final DateTime createdAt;
  final String author;
  final String? userRole;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.author,
    this.userRole,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      content: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['author'] as String,
      userRole: json['user_role'] as String?,
    );
  }
} 