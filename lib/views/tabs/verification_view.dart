import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pending_user_model.dart';
import '../../providers/pending_users_provider.dart';
import '../../providers/user_provider.dart';

class VerificationView extends ConsumerWidget {
  final String chatboardId;

  const VerificationView({
    Key? key,
    required this.chatboardId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final pendingUsersAsync = ref.watch(pendingUsersProvider(chatboardId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Verification'),
      ),
      body: userAsync.when(
        data: (user) {
          // Check if user has required roles
          final hasRequiredRole = user.hasAnyRole(['Admin', 'Abisarvik', 'Peasarvik']);
          if (!hasRequiredRole) {
            return const Center(
              child: Text('You do not have permission to view this page.'),
            );
          }

          return pendingUsersAsync.when(
            data: (pendingUsersResponse) {
              if (pendingUsersResponse.pendingUsers.isEmpty) {
                return const Center(
                  child: Text('No pending users to verify.'),
                );
              }

              return ListView.builder(
                itemCount: pendingUsersResponse.pendingUsers.length,
                itemBuilder: (context, index) {
                  final pendingUser = pendingUsersResponse.pendingUsers[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('${pendingUser.firstName} ${pendingUser.lastName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${pendingUser.email}'),
                          Text('Squad: ${pendingUser.squadName}'),
                          Text('Status: ${pendingUser.status}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _verifyUser(
                              context,
                              ref,
                              pendingUser,
                              'Approved',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _verifyUser(
                              context,
                              ref,
                              pendingUser,
                              'Rejected',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading pending users: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user data: $error'),
        ),
      ),
    );
  }

  Future<void> _verifyUser(
    BuildContext context,
    WidgetRef ref,
    PendingUser pendingUser,
    String status,
  ) async {
    try {
      print('Verifying user ${pendingUser.userId} with status: $status');
      
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing verification...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      // Create the verification parameters
      final params = {
        'chatboardId': chatboardId,
        'userId': pendingUser.userId,
        'squadId': pendingUser.squadId,
        'status': status,
      };
      
      print('Verification params: $params');
      
      // Call the verification provider
      final success = await ref.read(verifyUserProvider(params).future);
      
      print('Verification result: $success');
      
      if (success) {
        // Refresh the pending users list
        ref.invalidate(pendingUsersProvider(chatboardId));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User ${status.toLowerCase()} successfully'),
            backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error verifying user: $e');
      
      // Extract a user-friendly error message
      String errorMessage = 'Error verifying user';
      if (e.toString().contains('Server error')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else if (e.toString().contains('Failed to commit changes')) {
        errorMessage = 'Failed to update user status. Please try again later.';
      }
      
      // Show a more detailed error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Verification Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      // Also show a snackbar for quick feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 