import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unicorn_app_frontend/views/auth_view.dart';
import 'package:unicorn_app_frontend/views/authentication/register/register_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthView();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterView();
      },
    ),
  ],
  );