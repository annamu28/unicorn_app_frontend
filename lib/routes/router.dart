import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unicorn_app_frontend/views/add_chatboard/add_chatboard_view.dart';
import 'package:unicorn_app_frontend/views/add_post/add_post_view.dart';
import 'package:unicorn_app_frontend/views/auth_view.dart';
import 'package:unicorn_app_frontend/views/authentication/register/register_view.dart';
import 'package:unicorn_app_frontend/views/avatar/avatar_view.dart';
import '../views/main/main_view.dart';
import '../views/chatboard/chatboard_view.dart';
import '../views/post/post_view.dart';
//import '../views/add_post/add_post_view.dart';

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
    GoRoute(
      path: '/avatar',
      builder: (BuildContext context, GoRouterState state) {
        return const AvatarView();
      },
    ),
    GoRoute(
      path: '/main',
      builder: (BuildContext context, GoRouterState state) {
        return const MainView();
      },
    ),
    GoRoute(
      path: '/create-chatboard',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateNewChatboardView();
      },
    ),
    GoRoute(
      path: '/chatboard/:id',
      builder: (BuildContext context, GoRouterState state) {
        return ChatboardView(
          chatboardId: state.pathParameters['id']!,
        );
      },
    ),
    GoRoute(
      path: '/add-post/:chatboardId',
      builder: (BuildContext context, GoRouterState state) {
        return AddPostView(
          chatboardId: state.pathParameters['chatboardId']!,
        );
      },
    ),
    GoRoute(
      path: '/post/:chatboardId/:postId',
      builder: (BuildContext context, GoRouterState state) {
        return PostView(
          chatboardId: state.pathParameters['chatboardId']!,
          postId: state.pathParameters['postId']!,
        );
      },
    ),
  ],
);