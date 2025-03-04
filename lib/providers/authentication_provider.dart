import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/api_service.dart';
import 'package:unicorn_app_frontend/state/auth_result.dart';
import 'package:unicorn_app_frontend/state/auth_state.dart';

class AuthenticationNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthenticationNotifier({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(AuthState.unknown());

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.login(email, password);

      if (response['result'] == 'success') {
        // Store the token securely (consider using flutter_secure_storage)
        state = state.copyWith(
          result: AuthResult.success,
          isLoading: false,
          token: response['token'],
        );
      } else {
        state = state.copyWith(
          result: AuthResult.failure,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        result: AuthResult.failure,
        isLoading: false,
      );
    }
  }

  Future<void> registerWithEmailAndPassword(
      String firstName, String lastName, String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.register(firstName, lastName, email, password);

      if (response['token'] != null) {
        state = state.copyWith(
          result: AuthResult.success,
          isLoading: false,
          token: response['token'],
        );
      } else {
        // Check for specific error messages
        if (response['error'] == 'Email already exists') {
          state = state.copyWith(
            result: AuthResult.alreadyExists,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            result: AuthResult.failure,
            isLoading: false,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        result: AuthResult.failure,
        isLoading: false,
      );
    }
  }

  void logout() {
    state = AuthState.unknown();  // Reset to initial state
  }
}

final authenticationProvider =
    StateNotifierProvider<AuthenticationNotifier, AuthState>((ref) {
  return AuthenticationNotifier();
});

final authenticationNotifier = authenticationProvider.notifier;

final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authenticationProvider);
  return authState.token != null && authState.result == AuthResult.success;
});
