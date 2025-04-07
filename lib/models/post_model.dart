class PostAuthor {
  final String firstName;
  final String lastName;
  final String? email;

  PostAuthor({
    required this.firstName,
    required this.lastName,
    this.email,
  });

  factory PostAuthor.fromJson(dynamic json) {
    if (json is String) {
      // Handle case where author is just a string
      return PostAuthor(
        firstName: json.split(' ').first,
        lastName: json.split(' ').skip(1).join(' '),
        email: null,
      );
    }
    
    // Handle case where author is an object
    final authorMap = json as Map<String, dynamic>;
    return PostAuthor(
      firstName: authorMap['first_name'] as String,
      lastName: authorMap['last_name'] as String,
      email: authorMap['email'] as String?,
    );
  }
}

class Post {
  final int id;
  final int? chatboardId;
  final int? userId;
  final String title;
  final String content;
  final bool pinned;
  final DateTime createdAt;
  final PostAuthor author;
  final int? commentCount;
  final String? userRole;

  Post({
    required this.id,
    this.chatboardId,
    this.userId,
    required this.title,
    required this.content,
    required this.pinned,
    required this.createdAt,
    required this.author,
    this.commentCount,
    this.userRole,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      chatboardId: json['chatboard_id'] as int?,
      userId: json['user_id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      pinned: json['pinned'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: PostAuthor.fromJson(json['author']),
      commentCount: json['comment_count'] as int?,
      userRole: json['user_role'] as String?,
    );
  }

  factory Post.fromCreateResponse(Map<String, dynamic> json, int chatboardId) {
    return Post(
      id: json['id'] as int,
      chatboardId: chatboardId,
      title: json['title'] as String,
      content: json['content'] as String,
      pinned: json['pinned'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: PostAuthor.fromJson(json['author']),
    );
  }
} 