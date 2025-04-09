import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/dio_provider.dart';

final postServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return PostService(dio);
});

final postsProvider = FutureProvider.family<List<Post>, String>((ref, chatboardId) async {
  final postService = ref.watch(postServiceProvider);
  return postService.getPosts(chatboardId);
});

// Provider to refresh posts after comment changes
final refreshPostsProvider = Provider<void Function(String)>((ref) {
  return (String chatboardId) {
    ref.invalidate(postsProvider(chatboardId));
  };
}); 