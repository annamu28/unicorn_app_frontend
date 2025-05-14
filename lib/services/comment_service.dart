import 'package:dio/dio.dart';
import '../models/comment_model.dart';

class CommentService {
  final Dio _dio;

  CommentService(this._dio);

  Future<List<Comment>> getComments(String postId) async {
    try {
      print('Fetching comments for post: $postId');
      final url = '/comments?post_id=$postId';
      print('Comments URL: $url');
      
      final response = await _dio.get(url);
      print('Comments response: ${response.data}');
      print('Full URL: ${response.requestOptions.uri}');
      
      if (response.data == null) {
        return [];
      }

      final List<dynamic> commentsJson = response.data as List;
      print('Number of comments found: ${commentsJson.length}');
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
      // Create the comment
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

      // Update the post's comment count
      try {
        await _dio.patch(
          '/posts/$postId/increment-comments',
          data: {
            'increment': 1,
          },
        );
        print('Updated post comment count');
      } catch (e) {
        print('Error updating post comment count: $e');
        // Don't throw here, we still want to return the created comment
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