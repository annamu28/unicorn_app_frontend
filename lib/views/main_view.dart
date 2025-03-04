import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import 'package:unicorn_app_frontend/views/constants/strings.dart';
import 'package:unicorn_app_frontend/views/dialogs/alert_dialog_model.dart';
import 'package:unicorn_app_frontend/views/dialogs/logout_dialog.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50), // Makes button stretch horizontally
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () async {
              final shouldLogOut = await const LogoutDialog().present(context).then(
                    (value) => value ?? false,
                  );

              if (shouldLogOut) {
                ref.read(authenticationProvider.notifier).logout();
                context.go('/'); // Navigate to login screen
              }
            },
            child: const Text(
              Strings.logOut,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
