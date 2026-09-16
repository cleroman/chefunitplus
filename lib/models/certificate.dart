// =============================================================
// ChefUnitPlus - Modle Certificate
// Dlivr  un apprenant aprs validation d'une formation
// =============================================================

class Certificate {
  final String id;
  final String userId;
  final String userName;
  final String formationId;
  final String formationTitle;
  final String? directorName; // signataire
  final String? trainerName;
  final String certificateNumber; // numro unique de certificat
  final String? pdfUrl; // lien vers le PDF hberg
  final DateTime issuedAt;
  final DateTime? expiresAt;

  String? learnerName; // null = permanent

  Certificate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.formationId,
    required this.formationTitle,
    this.directorName,
    this.trainerName,
    required this.certificateNumber,
    this.pdfUrl,
    required this.issuedAt,
    this.expiresAt,
  });

  // ===========================================================
  // Y FACTORIES
  // ===========================================================
  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: json['userName'] ?? '',
      formationId: (json['formationId'] ?? '').toString(),
      formationTitle: json['formationTitle'] ?? '',
      directorName: json['directorName'],
      trainerName: json['trainerName'],
      certificateNumber: json['certificateNumber'] ?? '',
      pdfUrl: json['pdfUrl'],
      issuedAt: _parseDate(json['issuedAt']) ?? DateTime.now(),
      expiresAt: _parseDate(json['expiresAt']),
    );
  }

  // ===========================================================
  // Y" S?RIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'formationId': formationId,
        'formationTitle': formationTitle,
        if (directorName != null) 'directorName': directorName,
        if (trainerName != null) 'trainerName': trainerName,
        'certificateNumber': certificateNumber,
        if (pdfUrl != null) 'pdfUrl': pdfUrl,
        'issuedAt': issuedAt.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      };

  // ===========================================================
  // Y"< COPYWITH
  // ===========================================================
  Certificate copyWith({
    String? id,
    String? userId,
    String? userName,
    String? formationId,
    String? formationTitle,
    String? directorName,
    String? trainerName,
    String? certificateNumber,
    String? pdfUrl,
    DateTime? issuedAt,
    DateTime? expiresAt,
  }) {
    return Certificate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      formationId: formationId ?? this.formationId,
      formationTitle: formationTitle ?? this.formationTitle,
      directorName: directorName ?? this.directorName,
      trainerName: trainerName ?? this.trainerName,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // ===========================================================
  // Y" GETTERS
  // ===========================================================
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
  bool get isPermanent => expiresAt == null;
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isValid => !isExpired;

  // ===========================================================
  // Y COMPARAISON
  // ===========================================================
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Certificate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Certificate(n $certificateNumber, user: $userName, formation: $formationTitle)';

  // ===========================================================
  // Y HELPERS PRIV?S
  // ===========================================================
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
