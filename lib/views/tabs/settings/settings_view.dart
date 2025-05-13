import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/authentication_provider.dart';
import '../../dialogs/logout_dialog.dart';
import '../../../services/dio_provider.dart';
import '../../constants/strings.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);
    final authService = ref.watch(authServiceProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          onPressed: () async {
            final shouldLogOut = await const LogoutDialog()
                .present(context)
                .then((value) => value ?? false);

            if (shouldLogOut) {
              try {
                final refreshToken = authState.userInfo?['refresh_token'] as String?;
                final accessToken = authState.token;
                
                if (refreshToken != null && accessToken != null) {
                  await authService.logout(accessToken, refreshToken);
                }
                ref.read(authenticationProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
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
    );
  }
}
