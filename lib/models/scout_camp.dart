// =============================================================
// ChefUnitPlus - ScoutCamp
// Représente un camp scout auquel un utilisateur a participé
// =============================================================

class ScoutCamp {
  final String id;
  final String userId;

  final String nom;
  final String lieu;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String role; // Participant, Chef, Adjoint, etc.

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScoutCamp({
    required this.id,
    required this.userId,
    required this.nom,
    required this.lieu,
    required this.dateDebut,
    required this.dateFin,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  // ===========================================================
  // 🏭 FACTORY
  // ===========================================================
  factory ScoutCamp.fromJson(Map<String, dynamic> json) {
    return ScoutCamp(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      nom: json['nom'] ?? json['name'] ?? '',
      lieu: json['lieu'] ?? json['location'] ?? '',
      dateDebut:
          _parseDate(json['dateDebut'] ?? json['date_debut']) ?? DateTime.now(),
      dateFin:
          _parseDate(json['dateFin'] ?? json['date_fin']) ?? DateTime.now(),
      role: json['role'] ?? 'Participant',
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  // ===========================================================
  // 📤 SÉRIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'nom': nom,
        'lieu': lieu,
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
        'role': role,
      };

  // ===========================================================
  // 📋 COPYWITH
  // ===========================================================
  ScoutCamp copyWith({
    String? id,
    String? userId,
    String? nom,
    String? lieu,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScoutCamp(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      lieu: lieu ?? this.lieu,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===========================================================
  // 🔍 GETTERS
  // ===========================================================
  int get dureeJours => dateFin.difference(dateDebut).inDays + 1;

  String get periodeLabel {
    final d1 = '${dateDebut.day}/${dateDebut.month}/${dateDebut.year}';
    final d2 = '${dateFin.day}/${dateFin.month}/${dateFin.year}';
    return '$d1 → $d2';
  }

  // ===========================================================
  // 🧰 HELPERS
  // ===========================================================
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
