class Program {
  final String id;
  final String name;
  final String? shortName;
  final int tokensCount;
  final String briefDescription;
  final String companyId;
  final String companyName;
  final String registrationNumber;
  final bool active;
  final String? imageId;
  final String agreementId;
  final String? frameColor;
  final String notificationsSender;
  final double? tokenValue;
  final DateTime? tokenValueCalculatedDate;
  final String status;
  final String? promise;

  Program({
    required this.id,
    required this.name,
    this.shortName,
    required this.tokensCount,
    required this.briefDescription,
    required this.companyId,
    required this.companyName,
    required this.registrationNumber,
    required this.active,
    this.imageId,
    required this.agreementId,
    this.frameColor,
    required this.notificationsSender,
    this.tokenValue,
    this.tokenValueCalculatedDate,
    required this.status,
    this.promise,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['shortName']?.toString(),
      tokensCount: json['tokensCount'] as int? ?? 0,
      briefDescription: json['briefDescription']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      registrationNumber: json['registrationNumber']?.toString() ?? '',
      active: json['active'] as bool? ?? false,
      imageId: json['imageId']?.toString(),
      agreementId: json['agreementId']?.toString() ?? '',
      frameColor: json['frameColor']?.toString(),
      notificationsSender: json['notificationsSender']?.toString() ?? '',
      tokenValue: json['tokenValue']?.toDouble(),
      tokenValueCalculatedDate: json['tokenValueCalculatedDate'] != null 
          ? DateTime.tryParse(json['tokenValueCalculatedDate'].toString())
          : null,
      status: json['status']?.toString() ?? '',
      promise: json['promise']?.toString(),
    );
  }
} 