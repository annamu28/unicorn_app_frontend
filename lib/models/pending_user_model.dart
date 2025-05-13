class PendingUser {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final int squadId;
  final String squadName;
  final String status;
  final String role;

  PendingUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.squadId,
    required this.squadName,
    required this.status,
    required this.role,
  });

  factory PendingUser.fromJson(Map<String, dynamic> json) {
    return PendingUser(
      userId: json['user_id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      squadId: json['squad_id'] as int,
      squadName: json['squad_name'] as String,
      status: json['status'] as String,
      role: json['role'] as String? ?? 'Unknown',
    );
  }
}

class PendingUsersResponse {
  final List<PendingUser> pendingUsers;
  final int count;

  PendingUsersResponse({
    required this.pendingUsers,
    required this.count,
  });

  factory PendingUsersResponse.fromJson(Map<String, dynamic> json) {
    return PendingUsersResponse(
      pendingUsers: (json['pending_users'] as List)
          .map((user) => PendingUser.fromJson(user))
          .toList(),
      count: json['count'] as int,
    );
  }
} 