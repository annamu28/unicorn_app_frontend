import 'package:dio/dio.dart';
import '../config/api_config.dart';

class AuthService {
  final Dio _dio;

  AuthService() : _dio = Dio()
    ..options.baseUrl = ApiConfig.baseUrl
    ..options.connectTimeout = ApiConfig.connectionTimeout
    ..options.receiveTimeout = ApiConfig.receiveTimeout
    ..options.sendTimeout = ApiConfig.sendTimeout;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Login with endpoint: ${_dio.options.baseUrl}/login');
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      
      print('Login response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Login endpoint: ${_dio.options.baseUrl}/login');
      print('Request data: email=$email');
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        error: 'Login failed: ${e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required DateTime birthday,
  }) async {
    try {
      print('Registering with endpoint: ${_dio.options.baseUrl}/register');
      final response = await _dio.post(
        '/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'birthday': birthday.toIso8601String().split('T')[0],
        },
      );
      print('Register response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Auth Service Register Error: $e');
      rethrow;
    }
  }

  Future<void> logout(String accessToken, String refreshToken) async {
    try {
      print('Logout with endpoint: ${_dio.options.baseUrl}/logout');
      final response = await _dio.post(
        '/logout',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => status! < 500, // Accept any status less than 500
        ),
      );
      print('Logout response: ${response.data}');
      
      // Even if we get a 400 status, we consider the logout successful
      // as the tokens are invalidated on the server
      return;
    } catch (e) {
      print('Auth Service Logout Error: $e');
      // We don't rethrow the error as we want to clear the local state
      // even if the server request fails
      return;
    }
  }
} 