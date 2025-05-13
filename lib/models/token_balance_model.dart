class Person {
  final String firstName;
  final String lastName;
  final String? email;
  final DateTime dateOfBirth;
  final String addressCountryCode;

  Person({
    required this.firstName,
    required this.lastName,
    this.email,
    required this.dateOfBirth,
    required this.addressCountryCode,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw Exception('Person JSON is null');
    }

    return Person(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString(),
      dateOfBirth: DateTime.tryParse(json['dateOfBirth']?.toString() ?? '') ?? DateTime.now(),
      addressCountryCode: json['addressCountryCode']?.toString() ?? '',
    );
  }
}

class TokenBalance {
  final String type;
  final Person? person;
  final dynamic organisation;
  final int tokenAmount;
  final String participationStatus;

  TokenBalance({
    required this.type,
    this.person,
    this.organisation,
    required this.tokenAmount,
    required this.participationStatus,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw Exception('TokenBalance JSON is null');
    }

    return TokenBalance(
      type: json['type']?.toString() ?? 'UNKNOWN',
      person: json['person'] != null ? Person.fromJson(json['person'] as Map<String, dynamic>) : null,
      organisation: json['organisation'],
      tokenAmount: json['tokenAmount'] as int? ?? 0,
      participationStatus: json['participationStatus']?.toString() ?? 'UNKNOWN',
    );
  }
} 