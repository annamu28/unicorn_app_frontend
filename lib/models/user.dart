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
  final String username;
  final List<String> roles;
  final List<Squad> squads;
  final List<String> countries;

  User({
    required this.username,
    required this.roles,
    required this.squads,
    required this.countries,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      roles: List<String>.from(json['roles'] as List),
      squads: (json['squads'] as List).map((squad) => Squad.fromJson(squad as Map<String, dynamic>)).toList(),
      countries: List<String>.from(json['countries'] as List),
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
