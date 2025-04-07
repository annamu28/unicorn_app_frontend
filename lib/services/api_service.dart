import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio()
    ..options.baseUrl = ApiConfig.baseUrl
    ..options.connectTimeout = ApiConfig.timeout
    ..options.receiveTimeout = ApiConfig.timeout;

  static final http.Client _client = http.Client();
  
  static Future<Map<String, dynamic>> _handleRequest(Future<http.Response> request) async {
    try {
      final response = await request;
      print('API Response Status: ${response.statusCode}');
      print('API Response Headers: ${response.headers}');
      print('API Response Body: ${response.body}');
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      switch (response.statusCode) {
        case 200:
        case 201:
          return data;
        case 401:
          return {'error': 'Invalid credentials'};
        case 409:
          return {'error': 'Email already exists'};
        case 500:
          print('Server error details: ${response.body}');
          return {'error': data['error'] ?? 'Server error occurred'};
        default:
          return {'error': data['error'] ?? 'Unknown error occurred'};
      }
    } catch (e) {
      print('API Error Details: $e');
      if (e is FormatException) {
        return {'error': 'Invalid response format'};
      }
      return {'error': e.toString()};
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/health'));
      print('Connection test: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
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

  static Future<Map<String, dynamic>> register({
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
      print('API Service Register Error: $e');
      rethrow;
    }
  }
}
