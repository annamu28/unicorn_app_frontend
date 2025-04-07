import 'package:flutter/foundation.dart';
import 'auth_result.dart';

@immutable
class AuthState {
  final bool isLoading;
  final AuthResult result;
  final String? token;
  final bool isAuthenticated;
  final Map<String, dynamic>? userInfo;

  const AuthState({
    this.isLoading = false,
    this.result = AuthResult.none,
    this.token,
    this.isAuthenticated = false,
    this.userInfo,
  });

  AuthState copyWith({
    bool? isLoading,
    AuthResult? result,
    String? token,
    bool? isAuthenticated,
    Map<String, dynamic>? userInfo,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}