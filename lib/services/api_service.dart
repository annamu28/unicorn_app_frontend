import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio()
    ..options.baseUrl = ApiConfig.baseUrl
    ..options.connectTimeout = ApiConfig.connectionTimeout
    ..options.receiveTimeout = ApiConfig.receiveTimeout
    ..options.sendTimeout = ApiConfig.sendTimeout;

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
}
