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
      // First check if we have access to the post
      try {
        final postResponse = await _dio.get('/posts/$postId');
        print('Post access check response: ${postResponse.data}');
        
        // Check if the post exists and is accessible
        if (postResponse.data == null) {
          throw Exception('Post not found');
        }
      } catch (e) {
        print('Error checking post access: $e');
        if (e is DioException && e.response?.statusCode == 403) {
          throw Exception('You do not have permission to comment on this post');
        }
        rethrow;
      }
      
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

      // Get current comment count
      try {
        final postResponse = await _dio.get('/posts/$postId');
        final currentCount = (postResponse.data['comment_count'] as num?)?.toInt() ?? 0;
        
        // Update the post's comment count
        await _dio.patch(
          '/posts/$postId',
          data: {
            'comment_count': currentCount + 1, // Increment by 1
          },
        );
        print('Updated post comment count from $currentCount to ${currentCount + 1}');
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
        
        // Handle specific error cases
        if (e.response?.statusCode == 500 && e.response?.data['error'] == 'Failed to verify access') {
          throw Exception('You do not have permission to comment on this post');
        }
      }
      rethrow;
    }
  }
} 