import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/authentication_provider.dart';

class UserService {
  final Dio _dio;
  final ProviderRef _ref;

  UserService(this._dio, this._ref);

  Future<User> getUserInfo() async {
    try {
      print('Fetching user info');
      final response = await _dio.get('/userinfo');
      print('User info response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Received null response when fetching user info');
      }

      // Get the user_id from the authentication state
      final authState = _ref.read(authenticationProvider);
      final userId = authState.userInfo?['user_id'];
      
      if (userId == null) {
        throw Exception('User ID not found in authentication state');
      }

      // Add the user_id to the response data
      final userData = Map<String, dynamic>.from(response.data as Map<String, dynamic>);
      userData['user_id'] = userId;

      return User.fromJson(userData);
    } catch (e) {
      print('Error fetching user info: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }
} 