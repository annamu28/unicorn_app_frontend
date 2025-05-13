import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../services/api_service.dart';
import '../state/auth_state.dart';
import '../state/auth_result.dart';
import '../services/auth_service.dart';

class AuthenticationNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthenticationNotifier(this._authService) : super(const AuthState());

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, result: AuthResult.none);
      
      final response = await _authService.login(email, password);
      
      // Debug prints
      print('Login response: $response');
      
      if (response is Map<String, dynamic>) {
        final token = response['access_token'] as String?;
        final refreshToken = response['refresh_token'] as String?;
        final userId = response['user_id'];
        final firstName = response['first_name'] as String?;
        final lastName = response['last_name'] as String?;
        final userEmail = response['email'] as String?;

        if (token == null) {
          throw Exception('Token is null in response');
        }

        state = state.copyWith(
          isLoading: false,
          result: AuthResult.success,
          token: token,
          isAuthenticated: true,
          userInfo: {
            'first_name': firstName ?? '',
            'last_name': lastName ?? '',
            'email': userEmail ?? '',
            'user_id': userId,
            'refresh_token': refreshToken,
          },
        );
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Login error: $e');
      state = state.copyWith(
        isLoading: false,
        result: AuthResult.failure,
      );
      rethrow;
    }
  }

  Future<void> registerWithEmailAndPassword(
    String firstName,
    String lastName,
    String email,
    String password,
    DateTime birthdate,
  ) async {
    try {
      state = state.copyWith(isLoading: true, result: AuthResult.none);
      
      final Map<String, dynamic> response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        birthday: birthdate,
      );

      if (response.containsKey('error')) {
        state = state.copyWith(
          isLoading: false,
          result: AuthResult.failure,
        );
        return;
      }

      final token = response['access_token'] as String;
      final userInfo = {
        'first_name': response['first_name'],
        'last_name': response['last_name'],
        'email': response['email'],
        'user_id': response['user_id'],
        'refresh_token': response['refresh_token'],
      };

      print('Registration response: $response');
      print('User info: $userInfo');

      state = state.copyWith(
        isLoading: false,
        result: AuthResult.success,
        token: token,
        isAuthenticated: true,
        userInfo: userInfo,
      );
    } catch (e) {
      print('Registration error: $e');
      state = state.copyWith(
        isLoading: false,
        result: AuthResult.failure,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (state.token != null && state.userInfo?['refresh_token'] != null) {
        await _authService.logout(state.token!, state.userInfo!['refresh_token']);
      }
      state = AuthState();
    } catch (e) {
      print('Logout error: $e');
      // Even if the API call fails, we still want to clear the local state
      state = AuthState();
    }
  }
}

final authenticationProvider =
    StateNotifierProvider<AuthenticationNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthenticationNotifier(authService);
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authenticationProvider).isAuthenticated;
});
