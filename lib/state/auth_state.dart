import 'package:unicorn_app_frontend/state/auth_result.dart';

class AuthState {
  final AuthResult result;
  final bool isLoading;
  final String? token;

  const AuthState({
    this.result = AuthResult.unknown,
    this.isLoading = false,
    this.token,
  });

  const AuthState.unknown()
      : result = AuthResult.unknown,
        isLoading = false,
        token = null;

  AuthState copyWith({
    AuthResult? result,
    bool? isLoading,
    String? token,
  }) {
    return AuthState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
    );
  }
}