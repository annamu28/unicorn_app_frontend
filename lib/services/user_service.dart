import 'package:dio/dio.dart';
import '../models/user.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<User> getUserInfo() async {
    try {
      print('Fetching user info');
      final response = await _dio.get('/userinfo');
      print('User info response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Received null response when fetching user info');
      }

      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching user info: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }
} 