// =============================================================
// ChefUnitPlus - Modele ScoutGroup
// =============================================================

class ScoutGroup {
  final String id;
  final String name;
  final String? description;
  final String? region;
  final String? district;
  final String? province;
  final String? ville;
  final String? commune;
  final String? quartier;
  final String? association;
  final String? branche;
  final String? groupeScout;
  final String? numeroAffiliation;
  final String? directorId;
  final String? directorName;
  final int membersCount;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScoutGroup({
    required this.id,
    required this.name,
    this.description,
    this.region,
    this.district,
    this.province,
    this.ville,
    this.commune,
    this.quartier,
    this.association,
    this.branche,
    this.groupeScout,
    this.numeroAffiliation,
    this.directorId,
    this.directorName,
    this.membersCount = 0,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // =========================================================
  // FROM JSON
  // =========================================================
  factory ScoutGroup.fromJson(Map<String, dynamic> json) {
    return ScoutGroup(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      description: json['description'],
      region: json['region'],
      district: json['district'],
      province: json['province'],
      ville: json['ville'],
      commune: json['commune'],
      quartier: json['quartier'],
      association: json['association'],
      branche: json['branche'],
      groupeScout: json['groupeScout'] ?? json['groupe_scout'],
      numeroAffiliation:
          json['numeroAffiliation'] ?? json['numero_affiliation'],
      directorId: json['director_id'] ?? json['directorId'],
      directorName: json['director_name'] ?? json['directorName'],
      membersCount: _parseInt(json['members_count'] ?? json['membersCount']),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  // =========================================================
  // TO JSON
  // =========================================================
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (region != null) 'region': region,
        if (district != null) 'district': district,
        if (province != null) 'province': province,
        if (ville != null) 'ville': ville,
        if (commune != null) 'commune': commune,
        if (quartier != null) 'quartier': quartier,
        if (association != null) 'association': association,
        if (branche != null) 'branche': branche,
        if (groupeScout != null) 'groupeScout': groupeScout,
        if (numeroAffiliation != null)
          'numeroAffiliation': numeroAffiliation,
        if (directorId != null) 'directorId': directorId,
        if (directorName != null) 'directorName': directorName,
        'membersCount': membersCount,
        'isActive': isActive,
        if (createdBy != null) 'createdBy': createdBy,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  // =========================================================
  // COPYWITH
  // =========================================================
  ScoutGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? region,
    String? district,
    String? province,
    String? ville,
    String? commune,
    String? quartier,
    String? association,
    String? branche,
    String? groupeScout,
    String? numeroAffiliation,
    String? directorId,
    String? directorName,
    int? membersCount,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScoutGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      region: region ?? this.region,
      district: district ?? this.district,
      province: province ?? this.province,
      ville: ville ?? this.ville,
      commune: commune ?? this.commune,
      quartier: quartier ?? this.quartier,
      association: association ?? this.association,
      branche: branche ?? this.branche,
      groupeScout: groupeScout ?? this.groupeScout,
      numeroAffiliation: numeroAffiliation ?? this.numeroAffiliation,
      directorId: directorId ?? this.directorId,
      directorName: directorName ?? this.directorName,
      membersCount: membersCount ?? this.membersCount,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================================================
  // =========================================================
  // GETTERS UTILES
  // =========================================================
  bool get hasDirector =>
      directorId != null && directorId!.isNotEmpty;

  bool get hasMembers => membersCount > 0;

  String get displayLocation {
    final parts = <String>[];
    if (region != null && region!.isNotEmpty) parts.add(region!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    return parts.join(' • ');
  }

  // HELPERS PRIVES
  // =========================================================
  static bool _parseBool(dynamic value, {bool defaultValue = true}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final v = value.toLowerCase().trim();
      return v == '1' || v == 'true' || v == 'yes';
    }
    return defaultValue;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  // =========================================================
  // COMPARAISON
  // =========================================================
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoutGroup &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ScoutGroup(id: $id, name: $name, region: $region)';
}