// =============================================================
// ChefUnitPlus - UserDetails
// Informations complÃ©mentaires du profil utilisateur
// (adresse, scouts, profession, santÃ©, engagement)
// =============================================================

enum ScoutBranch {
  louveteaux,
  eclaireurs,
  pionniers,
  routiers,
  autre,
}

extension ScoutBranchX on ScoutBranch {
  /// Valeur acceptee par le backend Node.js
  String get backendValue {
    switch (this) {
      case ScoutBranch.louveteaux:
        return 'meute';
      case ScoutBranch.eclaireurs:
        return 'troupe';
      case ScoutBranch.pionniers:
        return 'compagnie';
      case ScoutBranch.routiers:
        return 'clan';
      case ScoutBranch.autre:
        return 'troupe';
    }
  }

  String get label {
    switch (this) {
      case ScoutBranch.louveteaux:
        return 'Louveteaux';
      case ScoutBranch.eclaireurs:
        return 'Ã‰claireurs';
      case ScoutBranch.pionniers:
        return 'Pionniers';
      case ScoutBranch.routiers:
        return 'Routiers';
      case ScoutBranch.autre:
        return 'Autre';
    }
  }

  static ScoutBranch fromString(String? value) {
    if (value == null) return ScoutBranch.autre;
    return ScoutBranch.values.firstWhere(
      (b) => b.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ScoutBranch.autre,
    );
  }
}

class UserDetails {
  final String id;
  final String userId;

  // ------------------ ADRESSE ------------------
  final String province;
  final String commune;
  final String quartier;
  final String avenue;
  final String? numero;

  // ------------------ SCOUT ------------------
  final String groupeScout;
  final String numeroAffiliation;
  final String district;
  final String association;
  final ScoutBranch branche;
  final DateTime? dateEntreeScout;
  final String? fonctionScout;

  // ------------------ PROFESSION ------------------
  final String? profession;

  // ------------------ SANTÃ‰ ------------------
  final String? antecedentsMedicaux;
  final String? attestationCampUrl;

  // ------------------ ENGAGEMENT ------------------
  final bool engagementAccepte;
  final DateTime? engagementDate;

  // ------------------ MÃ‰TADONNÃ‰ES ------------------
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDetails({
    required this.id,
    required this.userId,
    required this.province,
    required this.commune,
    required this.quartier,
    required this.avenue,
    this.numero,
    required this.groupeScout,
    required this.numeroAffiliation,
    required this.district,
    required this.association,
    required this.branche,
    this.dateEntreeScout,
    this.fonctionScout,
    this.profession,
    this.antecedentsMedicaux,
    this.attestationCampUrl,
    this.engagementAccepte = false,
    this.engagementDate,
    this.createdAt,
    this.updatedAt,
  });

  // ===========================================================
  // ðŸ­ FACTORY
  // ===========================================================
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      province: json['province'] ?? '',
      commune: json['commune'] ?? '',
      quartier: json['quartier'] ?? '',
      avenue: json['avenue'] ?? '',
      numero: json['numero']?.toString(),
      groupeScout: json['groupeScout'] ?? json['groupe_scout'] ?? '',
      numeroAffiliation:
          json['numeroAffiliation'] ?? json['numero_affiliation'] ?? '',
      district: json['district'] ?? '',
      association: json['association'] ?? '',
      branche: ScoutBranchX.fromString(
        json['branche'] ?? json['branche_scout'],
      ),
      dateEntreeScout:
          _parseDate(json['dateEntreeScout'] ?? json['date_entree_scout']),
      fonctionScout: json['fonctionScout'] ?? json['fonction_scout'],
      profession: json['profession'],
      antecedentsMedicaux:
          json['antecedentsMedicaux'] ?? json['antecedents_medicaux'],
      attestationCampUrl:
          json['attestationCampUrl'] ?? json['attestation_camp_url'],
      engagementAccepte:
          json['engagementAccepte'] ?? json['engagement_accepte'] ?? false,
      engagementDate:
          _parseDate(json['engagementDate'] ?? json['engagement_date']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  // ===========================================================
  // ðŸ“¤ SÃ‰RIALISATION (envoyÃ© au backend Node.js)
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'province': province,
        'commune': commune,
        'quartier': quartier,
        'avenue': avenue,
        if (numero != null) 'numero': numero,
        'groupe_scout': groupeScout,
        'numero_affiliation': numeroAffiliation,
        'district': district,
        'association': association,
        'branche': branche.name,
        if (dateEntreeScout != null)
          'date_entree_scout': dateEntreeScout!.toIso8601String(),
        if (fonctionScout != null) 'fonction_scout': fonctionScout,
        if (profession != null) 'profession': profession,
        if (antecedentsMedicaux != null)
          'antecedents_medicaux': antecedentsMedicaux,
        if (attestationCampUrl != null)
          'attestation_camp_url': attestationCampUrl,
        'engagement_accepte': engagementAccepte,
        if (engagementDate != null)
          'engagement_date': engagementDate!.toIso8601String(),
      };

  // ===========================================================
  // ðŸ“‹ COPYWITH
  // ===========================================================
  UserDetails copyWith({
    String? id,
    String? userId,
    String? province,
    String? commune,
    String? quartier,
    String? avenue,
    String? numero,
    String? groupeScout,
    String? numeroAffiliation,
    String? district,
    String? association,
    ScoutBranch? branche,
    DateTime? dateEntreeScout,
    String? fonctionScout,
    String? profession,
    String? antecedentsMedicaux,
    String? attestationCampUrl,
    bool? engagementAccepte,
    DateTime? engagementDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDetails(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      province: province ?? this.province,
      commune: commune ?? this.commune,
      quartier: quartier ?? this.quartier,
      avenue: avenue ?? this.avenue,
      numero: numero ?? this.numero,
      groupeScout: groupeScout ?? this.groupeScout,
      numeroAffiliation: numeroAffiliation ?? this.numeroAffiliation,
      district: district ?? this.district,
      association: association ?? this.association,
      branche: branche ?? this.branche,
      dateEntreeScout: dateEntreeScout ?? this.dateEntreeScout,
      fonctionScout: fonctionScout ?? this.fonctionScout,
      profession: profession ?? this.profession,
      antecedentsMedicaux: antecedentsMedicaux ?? this.antecedentsMedicaux,
      attestationCampUrl: attestationCampUrl ?? this.attestationCampUrl,
      engagementAccepte: engagementAccepte ?? this.engagementAccepte,
      engagementDate: engagementDate ?? this.engagementDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===========================================================
  // ðŸ” GETTERS
  // ===========================================================
  String get adresseComplete {
    final parts = [
      avenue,
      if (numero != null && numero!.isNotEmpty) 'nÂ°$numero',
      quartier,
      commune,
      province,
    ];
    return parts.join(', ');
  }

  bool get isComplete =>
      province.isNotEmpty &&
      commune.isNotEmpty &&
      quartier.isNotEmpty &&
      avenue.isNotEmpty &&
      groupeScout.isNotEmpty &&
      numeroAffiliation.isNotEmpty &&
      district.isNotEmpty &&
      association.isNotEmpty;

  // ===========================================================
  // ðŸ§° HELPERS PRIVÃ‰S
  // ===========================================================
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
