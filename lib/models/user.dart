class Squad {
  final int id;
  final String name;
  final String status;
  final List<String> roles;

  Squad({
    required this.id,
    required this.name,
    required this.status,
    required this.roles,
  });

  factory Squad.fromJson(Map<String, dynamic> json) {
    return Squad(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      roles: List<String>.from(json['roles'] as List),
    );
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool hasAnyRole(List<String> roles) {
    return this.roles.any((role) => roles.contains(role));
  }

  bool hasAllRoles(List<String> roles) {
    return roles.every((role) => this.roles.contains(role));
  }
}

class User {
  final int id;
  final String username;
  final List<String> roles;
  final List<Squad> squads;
  final List<String> countries;

  User({
    required this.id,
    required this.username,
    required this.roles,
    required this.squads,
    required this.countries,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Get the user_id from the authentication state if available
    final userId = json['user_id'] as int? ?? json['id'] as int?;
    if (userId == null) {
      throw Exception('User ID is required but not found in the response');
    }

    return User(
      id: userId,
      username: json['username'] as String,
      roles: List<String>.from(json['roles'] as List),
      squads: (json['squads'] as List).map((squad) => Squad.fromJson(squad as Map<String, dynamic>)).toList(),
      countries: List<String>.from(json['countries'] as List),
    );
  }

  bool hasRole(String role) {
    // Check top-level roles
    if (roles.contains(role)) {
      return true;
    }
    
    // Check roles in all squads
    return squads.any((squad) => squad.hasRole(role));
  }

  bool hasAnyRole(List<String> roles) {
    // Check top-level roles
    if (this.roles.any((role) => roles.contains(role))) {
      return true;
    }
    
    // Check roles in all squads
    return squads.any((squad) => squad.hasAnyRole(roles));
  }

  bool hasAllRoles(List<String> roles) {
    // Check top-level roles
    if (!this.roles.every((role) => roles.contains(role))) {
      return false;
    }
    
    // Check roles in all squads
    return squads.every((squad) => squad.hasAllRoles(roles));
  }

  // Get all roles across all squads
  List<String> getAllRoles() {
    final Set<String> allRoles = Set<String>.from(roles);
    
    // Add roles from all squads
    for (final squad in squads) {
      allRoles.addAll(squad.roles);
    }
    
    return allRoles.toList();
  }

  bool hasRoleInSquad(String role, int squadId) {
    final squad = squads.firstWhere(
      (s) => s.id == squadId,
      orElse: () => Squad(id: -1, name: '', status: '', roles: []),
    );
    return squad.id != -1 && squad.hasRole(role);
  }

  bool hasAnyRoleInSquad(List<String> roles, int squadId) {
    final squad = squads.firstWhere(
      (s) => s.id == squadId,
      orElse: () => Squad(id: -1, name: '', status: '', roles: []),
    );
    return squad.id != -1 && squad.hasAnyRole(roles);
  }

  bool hasAllRolesInSquad(List<String> roles, int squadId) {
    final squad = squads.firstWhere(
      (s) => s.id == squadId,
      orElse: () => Squad(id: -1, name: '', status: '', roles: []),
    );
    return squad.id != -1 && squad.hasAllRoles(roles);
  }

  List<String> getRolesInSquad(int squadId) {
    final squad = squads.firstWhere(
      (s) => s.id == squadId,
      orElse: () => Squad(id: -1, name: '', status: '', roles: []),
    );
    return squad.id != -1 ? squad.roles : [];
  }

  bool isInSquad(int squadId) {
    return squads.any((squad) => squad.id == squadId);
  }
}
