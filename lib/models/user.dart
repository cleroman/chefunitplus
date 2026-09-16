// =============================================================
// ChefUnitPlus - Modele User (propre + safe parsing)
// =============================================================

import 'package:chefunitplus/models/role.dart';

enum UserSexe { masculin, feminin }

extension UserSexeX on UserSexe {
  String get label => this == UserSexe.masculin ? 'Masculin' : 'Feminin';
  String get short => this == UserSexe.masculin ? 'M' : 'F';

  static UserSexe fromString(String? value) {
    if (value == null) return UserSexe.masculin;
    final v = value.toLowerCase();
    if (v.startsWith('f') || v == 'femme' || v == 'feminin') {
      return UserSexe.feminin;
    }
    return UserSexe.masculin;
  }
}

class User {
  final String id;
  final String postNom;
  final String prenom;
  final String? prenom2;
  final UserSexe sexe;
  final DateTime? dateNaissance;
  final String? lieuNaissance;
  final String? photoUrl;
  final String email;
  final String phone;
  final UserRole role;
  final bool isActive;
  final String? token;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool profileCompleted;

  const User({
    required this.id,
    required this.postNom,
    required this.prenom,
    this.prenom2,
    required this.sexe,
    this.dateNaissance,
    this.lieuNaissance,
    this.photoUrl,
    required this.email,
    required this.phone,
    this.role = UserRole.apprenant,
    this.isActive = true,
    this.token,
    this.createdBy,
    this.createdAt,
    this.lastLoginAt,
    this.profileCompleted = false,
  });

  // ===========================================================
  // FACTORY
  // ===========================================================
  factory User.fromJson(Map<String, dynamic> json) {
    String postNom = json['postNom'] ?? json['post_nom'] ?? '';
    String prenom = json['prenom'] ?? '';
    String? prenom2 = json['prenom2'] ?? json['prenom_2'];

    if (postNom.isEmpty && prenom.isEmpty && json['fullName'] != null) {
      final parts = (json['fullName'] as String).trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        prenom = parts.first;
        postNom = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    return User(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      postNom: postNom,
      prenom: prenom,
      prenom2: prenom2,
      sexe: UserSexeX.fromString(json['sexe'] as String?),
      dateNaissance: _parseDate(json['dateNaissance'] ?? json['date_naissance']),
      lieuNaissance: json['lieuNaissance'] ?? json['lieu_naissance'],
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['telephone'] ?? '',
      role: UserRoleExtension.fromString(json['role'] as String?),
      isActive: _parseBool(json['isActive'] ?? json['is_active'], true),
      token: json['token'],
      createdBy: json['createdBy']?.toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      lastLoginAt: _parseDate(json['lastLoginAt'] ?? json['last_login_at']),
      profileCompleted: _parseBool(
        json['profileCompleted'] ?? json['profile_completed'],
        false,
      ),
    );
  }

  factory User.guest() => const User(
        id: 'guest',
        postNom: 'Invite',
        prenom: '',
        sexe: UserSexe.masculin,
        email: '',
        phone: '',
      );

  // ===========================================================
  // TO JSON
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'id': id,
        'postNom': postNom,
        'prenom': prenom,
        if (prenom2 != null) 'prenom2': prenom2,
        'sexe': sexe.short,
        if (dateNaissance != null)
          'dateNaissance': dateNaissance!.toIso8601String(),
        if (lieuNaissance != null) 'lieuNaissance': lieuNaissance,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'email': email,
        'phone': phone,
        'role': role.name,
        'isActive': isActive,
        if (token != null) 'token': token,
        if (createdBy != null) 'createdBy': createdBy,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (lastLoginAt != null)
          'lastLoginAt': lastLoginAt!.toIso8601String(),
        'profileCompleted': profileCompleted,
      };

  // ===========================================================
  // COPYWITH
  // ===========================================================
  User copyWith({
    String? id,
    String? postNom,
    String? prenom,
    String? prenom2,
    UserSexe? sexe,
    DateTime? dateNaissance,
    String? lieuNaissance,
    String? photoUrl,
    String? email,
    String? phone,
    UserRole? role,
    bool? isActive,
    String? token,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? profileCompleted,
  }) =>
      User(
        id: id ?? this.id,
        postNom: postNom ?? this.postNom,
        prenom: prenom ?? this.prenom,
        prenom2: prenom2 ?? this.prenom2,
        sexe: sexe ?? this.sexe,
        dateNaissance: dateNaissance ?? this.dateNaissance,
        lieuNaissance: lieuNaissance ?? this.lieuNaissance,
        photoUrl: photoUrl ?? this.photoUrl,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        token: token ?? this.token,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        profileCompleted: profileCompleted ?? this.profileCompleted,
      );

  // ===========================================================
  // GETTERS
  // ===========================================================
  bool get isAdmin => role == UserRole.admin;
  bool get isDirector => role == UserRole.directeur;
  bool get isTrainer => role == UserRole.formateur;
  bool get isLearner => role == UserRole.apprenant;
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  String get fullName {
    final parts = [prenom, postNom].where((s) => s.isNotEmpty).toList();
    return parts.join(' ');
  }

  String get initials {
    final p = prenom.isNotEmpty ? prenom[0] : '?';
    final n = postNom.isNotEmpty ? postNom[0] : '?';
    return '$p$n'.toUpperCase();
  }

  int? get age {
    if (dateNaissance == null) return null;
    final now = DateTime.now();
    int a = now.year - dateNaissance!.year;
    if (now.month < dateNaissance!.month ||
        (now.month == dateNaissance!.month &&
            now.day < dateNaissance!.day)) {
      a--;
    }
    return a;
  }

  // ===========================================================
  // HELPERS PRIVES
  // ===========================================================
  static bool _parseBool(dynamic v, bool defaultValue) {
    if (v == null) return defaultValue;
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $fullName, role: ${role.name})';
}