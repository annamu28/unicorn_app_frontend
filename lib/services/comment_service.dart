import 'package:dio/dio.dart';
import '../models/comment_model.dart';

class CommentService {
  final Dio _dio;

  CommentService(this._dio);

  Future<List<Comment>> getComments(String postId) async {
    try {
      final response = await _dio.get(
        '/comments',
        queryParameters: {
          'post_id': postId,
        },
      );
      print('Comments response: ${response.data}');
      
      if (response.data == null) {
        return [];
      }

      final List<dynamic> commentsJson = response.data as List;
      return commentsJson.map((json) {
        try {
          return Comment.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing comment: $json');
          print('Error: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching comments: $e');
      rethrow;
    }
  }

  Future<Comment> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/comments',
        data: {
          'post_id': int.parse(postId),
          'comment': content,
        },
      );
      print('Create comment request data: ${response.requestOptions.data}');
      print('Create comment response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Received null response when creating comment');
      }

      return Comment.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error creating comment: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request data: ${e.requestOptions.data}');
      }
      rethrow;
    }
  }
} 