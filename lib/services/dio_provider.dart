import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../providers/authentication_provider.dart';
import 'auth_service.dart';

// Base Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('Dio Log: $obj'),
  ));
  return dio;
});

// Authenticated Dio provider
final authenticatedDioProvider = Provider<Dio>((ref) {
  final authState = ref.watch(authenticationProvider);
  
  // Create a new Dio instance with the token
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authState.token != null ? 'Bearer ${authState.token}' : '',
    },
  ));
  
  print('Created authenticated Dio with headers: ${dio.options.headers}');
  return dio;
});

// Auth Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
}); 