import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import 'user_provider.dart';

final postServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return PostService(dio);
});

final postsProvider = FutureProvider.family<List<Post>, String>((ref, chatboardId) async {
  final postService = ref.watch(postServiceProvider);
  // Watch the user provider to refresh posts when user data changes
  ref.watch(userProvider);
  return postService.getPosts(chatboardId);
});

// Provider to refresh posts after comment changes
final refreshPostsProvider = Provider<void Function(String)>((ref) {
  return (String chatboardId) {
    ref.invalidate(postsProvider(chatboardId));
  };
}); 