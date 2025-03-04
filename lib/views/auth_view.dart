import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import 'package:unicorn_app_frontend/views/authentication/login/login_view.dart';
import 'package:unicorn_app_frontend/views/main_view.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authenticationProvider);
        
        // Check if user is logged in by verifying if we have a token
        if (authState.token != null) {
          return const MainView();
        } else {
          return const LoginView();
        }
      },
    );
  }
} 