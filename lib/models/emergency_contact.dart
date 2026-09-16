// =============================================================
// ChefUnitPlus - EmergencyContact
// Contact à prévenir en cas d'urgence
// =============================================================

class EmergencyContact {
  final String id;
  final String userId;

  final String nomComplet;
  final String relation; // Père, Mère, Frère, Époux(se), Ami(e)...
  final String telephone;
  final String? telephoneSecondaire;
  final String? adresse;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmergencyContact({
    required this.id,
    required this.userId,
    required this.nomComplet,
    required this.relation,
    required this.telephone,
    this.telephoneSecondaire,
    this.adresse,
    this.createdAt,
    this.updatedAt,
  });

  // ===========================================================
  // 🏭 FACTORY
  // ===========================================================
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      nomComplet:
          json['nomComplet'] ?? json['nom_complet'] ?? json['name'] ?? '',
      relation: json['relation'] ?? '',
      telephone: json['telephone'] ?? json['phone'] ?? '',
      telephoneSecondaire:
          json['telephoneSecondaire'] ?? json['telephone_secondaire'],
      adresse: json['adresse'] ?? json['address'],
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  // ===========================================================
  // 📤 SÉRIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'nom_complet': nomComplet,
        'relation': relation,
        'telephone': telephone,
        if (telephoneSecondaire != null)
          'telephone_secondaire': telephoneSecondaire,
        if (adresse != null) 'adresse': adresse,
      };

  // ===========================================================
  // 📋 COPYWITH
  // ===========================================================
  EmergencyContact copyWith({
    String? id,
    String? userId,
    String? nomComplet,
    String? relation,
    String? telephone,
    String? telephoneSecondaire,
    String? adresse,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nomComplet: nomComplet ?? this.nomComplet,
      relation: relation ?? this.relation,
      telephone: telephone ?? this.telephone,
      telephoneSecondaire: telephoneSecondaire ?? this.telephoneSecondaire,
      adresse: adresse ?? this.adresse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===========================================================
  // 🔍 GETTERS
  // ===========================================================
  bool get hasSecondaryPhone =>
      telephoneSecondaire != null && telephoneSecondaire!.isNotEmpty;

  // ===========================================================
  // 🧰 HELPERS
  // ===========================================================
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
