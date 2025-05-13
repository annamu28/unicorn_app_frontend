import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pending_user_model.dart';
import '../../../providers/chatboard_provider.dart';

class PendingUsers extends ConsumerWidget {
  final String chatboardId;
  final PendingUsersResponse pendingUsers;
  final Function(PendingUser) onApprove;
  final Function(PendingUser) onReject;

  const PendingUsers({
    super.key,
    required this.chatboardId,
    required this.pendingUsers,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pendingUsers.pendingUsers.isEmpty) {
      return const Center(
        child: Text('No pending users'),
      );
    }

    return ListView.builder(
      itemCount: pendingUsers.pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers.pendingUsers[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: ListTile(
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user.email}'),
                Text('Squad: ${user.squadName}'),
                Text('Role: ${user.role}'),
                Text('Status: ${user.status}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => onApprove(user),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => onReject(user),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 