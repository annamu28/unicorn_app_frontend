import 'package:dio/dio.dart';
import '../models/post_model.dart';

class PostService {
  final Dio _dio;

  PostService(this._dio);

  Future<List<Post>> getPosts(String chatboardId) async {
    try {
      print('Fetching posts for chatboard: $chatboardId');
      final url = '/posts?chatboard_id=$chatboardId&include_comment_count=true';
      print('Request URL: $url');
      
      final response = await _dio.get(url);
      print('Posts response: ${response.data}');
      print('Full URL: ${response.requestOptions.uri}');
      
      if (response.data == null) {
        return [];
      }

      final List<dynamic> postsJson = response.data as List;
      final List<Post> posts = [];
      
      for (var json in postsJson) {
        try {
          final postJson = json as Map<String, dynamic>;
          final post = Post.fromJson(postJson);
          posts.add(post);
        } catch (e) {
          print('Error parsing post: $json');
          print('Error: $e');
          continue; // Skip this post instead of rethrowing
        }
      }
      
      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
      }
      return []; // Return empty list instead of rethrowing
    }
  }

  Future<Post> createPost({
    required String chatboardId,
    required String title,
    required String content,
  }) async {
    try {
      final boardId = int.parse(chatboardId);
      final response = await _dio.post(
        '/posts',
        data: {
          'chatboard_id': boardId,
          'title': title,
          'content': content,
        },
      );
      print('Create post request data: ${response.requestOptions.data}');
      print('Create post response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Received null response when creating post');
      }

      try {
        return Post.fromCreateResponse(
          response.data as Map<String, dynamic>,
          boardId,
        );
      } catch (e) {
        print('Error parsing post response: ${response.data}');
        print('Parse error: $e');
        rethrow;
      }
    } catch (e) {
      print('Error creating post: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request data: ${e.requestOptions.data}');
      }
      rethrow;
    }
  }
} 