import 'package:dio/dio.dart';
import '../models/post_model.dart';

class PostService {
  final Dio _dio;

  PostService(this._dio);

  Future<List<Post>> getPosts(String chatboardId) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {
          'chatboard_id': chatboardId,
        },
      );
      print('Posts response: ${response.data}');
      
      if (response.data == null) {
        return [];
      }

      final List<dynamic> postsJson = response.data as List;
      return postsJson.map((json) {
        try {
          return Post.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing post: $json');
          print('Error: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
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