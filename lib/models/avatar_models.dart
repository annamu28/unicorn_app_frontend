class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Squad {
  final int id;
  final String name;

  Squad({required this.id, required this.name});

  factory Squad.fromJson(Map<String, dynamic> json) {
    return Squad(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      name: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': name,
    };
  }
}

class SquadRoleSelection {
  final int squadId;
  final int roleId;
  final String status;

  SquadRoleSelection({
    required this.squadId,
    required this.roleId,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'squad_id': squadId,
      'role_id': roleId,
      'status': status,
    };
  }
} 