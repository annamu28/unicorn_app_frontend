import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final url = dotenv.env['BACKEND_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BACKEND_URL is not configured in .env file');
    }
    return url;
  }

  // API endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String postsEndpoint = '/posts';
  static const String commentsEndpoint = '/comments';
  static const String chatboardsEndpoint = '/chatboards';
  static const String programsEndpoint = '/programs';
  static const String tokensEndpoint = '/tokens';

  // API timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Helper method to get full URL for an endpoint
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Helper method to get headers with authorization
  static Map<String, String> getHeadersWithAuth(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
} 