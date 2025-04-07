import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../services/comment_service.dart';
import '../models/comment_model.dart';
final commentServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return CommentService(dio);
});

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final commentService = ref.watch(commentServiceProvider);
  return commentService.getComments(postId);
}); 