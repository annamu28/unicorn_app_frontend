import 'package:flutter/material.dart';
import '../../../../models/pending_user_model.dart';

class UserList extends StatelessWidget {
  final List<PendingUser> users;
  final PendingUser? selectedUser;
  final Map<int, String> attendanceStatus;
  final Function(PendingUser) onUserSelected;

  const UserList({
    super.key,
    required this.users,
    required this.selectedUser,
    required this.attendanceStatus,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Text('No users found in this chatboard.'),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final status = attendanceStatus[user.userId];
          final isPresent = status == 'Present';
          final isAbsent = status == 'Absent';
          
          return ListTile(
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text('Email: ${user.email}'),
            selected: selectedUser == user,
            tileColor: isPresent 
              ? Colors.green.withOpacity(0.1) 
              : isAbsent 
                ? Colors.red.withOpacity(0.1) 
                : null,
            trailing: isPresent 
              ? const Icon(Icons.check_circle, color: Colors.green)
              : isAbsent 
                ? const Icon(Icons.cancel, color: Colors.red)
                : null,
            onTap: () => onUserSelected(user),
          );
        },
      ),
    );
  }
} 