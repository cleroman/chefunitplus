// =============================================================
// ChefUnitPlus - Flutter : Inscription Scout complete
// =============================================================

const fs = require('fs');
const path = require('path');

const BASE = process.cwd();

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Flutter Scout Registration');
console.log('===========================================================');
console.log('');

function w(rel, content) {
    const full = path.join(BASE, rel);
    const dir = path.dirname(full);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(full, content, 'utf8');
    console.log('  [+] ' + rel);
}

// =============================================================
// 1. MODEL : User (etendu Scout)
// =============================================================
w('lib/models/user.dart', `// =============================================================
// ChefUnitPlus - Modele User (etendu Scout)
// =============================================================

import 'role.dart';

class User {
  final String id;
  final String fullName;
  final String? postNom;
  final String? prenom;
  final String email;
  final String phone;
  final String? sexe;              // 'homme' | 'femme'
  final String? dateNaissance;
  final String? lieuNaissance;
  final String? photoUrl;
  final UserRole role;
  final bool isActive;
  final String? token;
  final String? avatarUrl;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.fullName,
    this.postNom,
    this.prenom,
    required this.email,
    required this.phone,
    this.sexe,
    this.dateNaissance,
    this.lieuNaissance,
    this.photoUrl,
    this.role = UserRole.apprenant,
    this.isActive = true,
    this.token,
    this.avatarUrl,
    this.createdBy,
    this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] ?? j['_id'] ?? '').toString(),
        fullName: j['full_name'] ?? j['fullName'] ?? j['name'] ?? '',
        postNom: j['post_nom'] ?? j['postNom'],
        prenom: j['prenom'],
        email: j['email'] ?? '',
        phone: j['phone'] ?? '',
        sexe: j['sexe'],
        dateNaissance: j['date_naissance'] ?? j['dateNaissance'],
        lieuNaissance: j['lieu_naissance'] ?? j['lieuNaissance'],
        photoUrl: j['photo_url'] ?? j['photoUrl'],
        role: UserRoleExtension.fromString(j['role'] as String?),
        isActive: j['isActive'] == true || j['is_active'] == 1,
        token: j['token'],
        avatarUrl: j['avatarUrl'],
        createdBy: j['createdBy']?.toString(),
        createdAt: _pd(j['createdAt'] ?? j['created_at']),
        lastLoginAt: _pd(j['lastLoginAt'] ?? j['last_login_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'post_nom': postNom,
        'prenom': prenom,
        'email': email,
        'phone': phone,
        'sexe': sexe,
        'date_naissance': dateNaissance,
        'lieu_naissance': lieuNaissance,
        'photo_url': photoUrl,
        'role': role.name,
        'is_active': isActive ? 1 : 0,
        if (token != null) 'token': token,
      };

  User copyWith({
    String? id,
    String? fullName,
    String? postNom,
    String? prenom,
    String? email,
    String? phone,
    String? sexe,
    String? dateNaissance,
    String? lieuNaissance,
    String? photoUrl,
    UserRole? role,
    bool? isActive,
    String? token,
    String? avatarUrl,
  }) =>
      User(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        postNom: postNom ?? this.postNom,
        prenom: prenom ?? this.prenom,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        sexe: sexe ?? this.sexe,
        dateNaissance: dateNaissance ?? this.dateNaissance,
        lieuNaissance: lieuNaissance ?? this.lieuNaissance,
        photoUrl: photoUrl ?? this.photoUrl,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        token: token ?? this.token,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdBy: createdBy,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
      );

  bool get isAdmin => role == UserRole.admin;
  bool get isDirector => role == UserRole.directeur;
  bool get isTrainer => role == UserRole.formateur;
  bool get isLearner => role == UserRole.apprenant;
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  String get initials {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '\${parts.first[0]}\${parts.last[0]}'.toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static DateTime? _pd(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
`);

// =============================================================
// 2. MODEL : UserDetails (etendu Scout)
// =============================================================
w('lib/models/user_details.dart', `// =============================================================
// ChefUnitPlus - Modele UserDetails (etendu Scout)
// =============================================================

class UserDetails {
  final String userId;

  // Adresse
  final String? address;
  final String? city;
  final String? country;
  final String? province;
  final String? commune;
  final String? quartier;
  final String? avenue;
  final String? numero;

  // Etudes
  final String? educationLevel;
  final String? educationField;
  final String? educationInstitution;
  final String? profession;

  // Scout
  final String? groupeScout;
  final String? numeroAffiliation;
  final String? district;
  final String? association;
  final String? branche;           // meute | troupe | compagnie | clan
  final String? dateEntreeScout;
  final String? fonctionScout;
  final String? scoutFormation;
  final String? scoutRole;

  // Medical
  final String? antecedentsMedicaux;
  final String? attestationCampUrl;

  // Engagement
  final bool engagementAccepte;
  final String? engagementDate;

  // Bio
  final String? bio;
  final String? groupName;
  final String? profilePhotoUrl;

  const UserDetails({
    required this.userId,
    this.address,
    this.city,
    this.country,
    this.province,
    this.commune,
    this.quartier,
    this.avenue,
    this.numero,
    this.educationLevel,
    this.educationField,
    this.educationInstitution,
    this.profession,
    this.groupeScout,
    this.numeroAffiliation,
    this.district,
    this.association,
    this.branche,
    this.dateEntreeScout,
    this.fonctionScout,
    this.scoutFormation,
    this.scoutRole,
    this.antecedentsMedicaux,
    this.attestationCampUrl,
    this.engagementAccepte = false,
    this.engagementDate,
    this.bio,
    this.groupName,
    this.profilePhotoUrl,
  });

  factory UserDetails.fromJson(Map<String, dynamic> j) => UserDetails(
        userId: (j['user_id'] ?? j['userId'] ?? '').toString(),
        address: j['address'],
        city: j['city'] ?? j['ville'],
        country: j['country'] ?? j['pays'],
        province: j['province'],
        commune: j['commune'],
        quartier: j['quartier'],
        avenue: j['avenue'],
        numero: j['numero'],
        educationLevel: j['education_level'] ?? j['educationLevel'],
        educationField: j['education_field'] ?? j['educationField'],
        educationInstitution:
            j['education_institution'] ?? j['educationInstitution'],
        profession: j['profession'],
        groupeScout: j['groupe_scout'] ?? j['groupeScout'],
        numeroAffiliation: j['numero_affiliation'] ?? j['numeroAffiliation'],
        district: j['district'],
        association: j['association'],
        branche: j['branche'],
        dateEntreeScout: j['date_entree_scout'] ?? j['dateEntreeScout'],
        fonctionScout: j['fonction_scout'] ?? j['fonctionScout'],
        scoutFormation: j['scout_formation'] ?? j['scoutFormation'],
        scoutRole: j['scout_role'] ?? j['scoutRole'],
        antecedentsMedicaux:
            j['antecedents_medicaux'] ?? j['antecedentsMedicaux'],
        attestationCampUrl:
            j['attestation_camp_url'] ?? j['attestationCampUrl'],
        engagementAccepte:
            j['engagement_accepte'] == 1 || j['engagementAccepte'] == true,
        engagementDate: j['engagement_date'] ?? j['engagementDate'],
        bio: j['bio'],
        groupName: j['group_name'] ?? j['groupName'],
        profilePhotoUrl: j['profile_photo_url'] ?? j['profilePhotoUrl'],
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'address': address,
        'city': city,
        'country': country,
        'province': province,
        'commune': commune,
        'quartier': quartier,
        'avenue': avenue,
        'numero': numero,
        'education_level': educationLevel,
        'education_field': educationField,
        'education_institution': educationInstitution,
        'profession': profession,
        'groupe_scout': groupeScout,
        'numero_affiliation': numeroAffiliation,
        'district': district,
        'association': association,
        'branche': branche,
        'date_entree_scout': dateEntreeScout,
        'fonction_scout': fonctionScout,
        'scout_formation': scoutFormation,
        'scout_role': scoutRole,
        'antecedents_medicaux': antecedentsMedicaux,
        'attestation_camp_url': attestationCampUrl,
        'engagement_accepte': engagementAccepte ? 1 : 0,
        'engagement_date': engagementDate,
        'bio': bio,
        'profile_photo_url': profilePhotoUrl,
      };

  static UserDetails empty(String userId) => UserDetails(userId: userId);
}
`);

// =============================================================
// 3. MODEL : ScoutCamp
// =============================================================
w('lib/models/scout_camp.dart', `// =============================================================
// ChefUnitPlus - Modele ScoutCamp
// Camp de formation suivi par un scout
// =============================================================

class ScoutCamp {
  final String? id;
  final String? userId;
  final String nomCamp;
  final int? annee;
  final String? lieu;
  final String? description;

  const ScoutCamp({
    this.id,
    this.userId,
    required this.nomCamp,
    this.annee,
    this.lieu,
    this.description,
  });

  factory ScoutCamp.fromJson(Map<String, dynamic> j) => ScoutCamp(
        id: j['id']?.toString(),
        userId: j['user_id']?.toString(),
        nomCamp: j['nom_camp'] ?? j['nomCamp'] ?? '',
        annee: j['annee'] != null ? int.tryParse(j['annee'].toString()) : null,
        lieu: j['lieu'],
        description: j['description'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'user_id': userId,
        'nomCamp': nomCamp,
        if (annee != null) 'annee': annee,
        if (lieu != null) 'lieu': lieu,
        if (description != null) 'description': description,
      };

  ScoutCamp copyWith({
    String? id,
    String? userId,
    String? nomCamp,
    int? annee,
    String? lieu,
    String? description,
  }) =>
      ScoutCamp(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        nomCamp: nomCamp ?? this.nomCamp,
        annee: annee ?? this.annee,
        lieu: lieu ?? this.lieu,
        description: description ?? this.description,
      );
}
`);

// =============================================================
// 4. MODEL : EmergencyContact
// =============================================================
w('lib/models/emergency_contact.dart', `// =============================================================
// ChefUnitPlus - Modele EmergencyContact
// Personne a prevenir en cas d'urgence
// =============================================================

class EmergencyContact {
  final String? id;
  final String? userId;
  final String nom;
  final String? postNom;
  final String? prenom;
  final String telephone;
  final String? adresse;
  final String? relation;

  const EmergencyContact({
    this.id,
    this.userId,
    required this.nom,
    this.postNom,
    this.prenom,
    required this.telephone,
    this.adresse,
    this.relation,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
        id: j['id']?.toString(),
        userId: j['user_id']?.toString(),
        nom: j['nom'] ?? '',
        postNom: j['post_nom'] ?? j['postNom'],
        prenom: j['prenom'],
        telephone: j['telephone'] ?? '',
        adresse: j['adresse'],
        relation: j['relation'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'user_id': userId,
        'nom': nom,
        if (postNom != null) 'postNom': postNom,
        if (prenom != null) 'prenom': prenom,
        'telephone': telephone,
        if (adresse != null) 'adresse': adresse,
        if (relation != null) 'relation': relation,
      };

  EmergencyContact copyWith({
    String? id,
    String? userId,
    String? nom,
    String? postNom,
    String? prenom,
    String? telephone,
    String? adresse,
    String? relation,
  }) =>
      EmergencyContact(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        nom: nom ?? this.nom,
        postNom: postNom ?? this.postNom,
        prenom: prenom ?? this.prenom,
        telephone: telephone ?? this.telephone,
        adresse: adresse ?? this.adresse,
        relation: relation ?? this.relation,
      );
}
`);

// =============================================================
// 5. MODEL : RegistrationData (donnees du formulaire)
// =============================================================
w('lib/models/registration_data.dart', `// =============================================================
// ChefUnitPlus - Modele RegistrationData
// Contient toutes les donnees du formulaire d'inscription
// =============================================================

import 'scout_camp.dart';
import 'emergency_contact.dart';

class RegistrationData {
  // --- Identite ---
  String nom = '';
  String postNom = '';
  String prenom = '';
  String sexe = 'homme';
  String dateNaissance = '';
  String lieuNaissance = '';
  String? photoPath;

  // --- Contact ---
  String telephone = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  // --- Adresse ---
  String province = '';
  String ville = '';
  String commune = '';
  String quartier = '';
  String avenue = '';
  String numero = '';

  // --- Scout ---
  String groupeScout = '';
  String numeroAffiliation = '';
  String district = '';
  String association = '';
  String branche = 'meute';
  String dateEntreeScout = '';
  String fonction = '';
  String profession = '';
  String niveauEtude = '';
  String antecedentsMedicaux = '';
  String? attestationCampUrl;

  // --- Camps ---
  List<ScoutCamp> camps = [];

  // --- Contacts d'urgence ---
  List<EmergencyContact> emergencyContacts = [];

  // --- Engagement ---
  bool engagementAccepte = false;

  RegistrationData();

  Map<String, dynamic> toJson() => {
        // Identite
        'nom': nom,
        'postNom': postNom,
        'prenom': prenom,
        'sexe': sexe,
        'dateNaissance': dateNaissance,
        'lieuNaissance': lieuNaissance,
        // Contact
        'phone': telephone,
        'email': email,
        'password': password,
        // Adresse
        'province': province,
        'ville': ville,
        'commune': commune,
        'quartier': quartier,
        'avenue': avenue,
        'numero': numero,
        // Scout
        'groupeScout': groupeScout,
        'numeroAffiliation': numeroAffiliation,
        'district': district,
        'association': association,
        'branche': branche,
        'dateEntreeScout': dateEntreeScout,
        'fonction': fonction,
        'profession': profession,
        'niveauEtude': niveauEtude,
        'antecedentsMedicaux': antecedentsMedicaux,
        'attestationCampUrl': attestationCampUrl,
        // Listes
        'camps': camps.map((c) => c.toJson()).toList(),
        'emergencyContacts':
            emergencyContacts.map((c) => c.toJson()).toList(),
        // Engagement
        'engagementAccepte': engagementAccepte,
      };
}
`);

// =============================================================
// 6. SERVICE : AuthService (register etendu)
// =============================================================
w('lib/services/auth_service.dart', `// =============================================================
// ChefUnitPlus - AuthService (register etendu Scout)
// =============================================================

import 'dart:async';

import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/auth_response.dart';
import '../models/registration_data.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient api;
  final StorageService storage;

  AuthService({required this.api, required this.storage});

  // ===========================================================
  // LOGIN
  // ===========================================================
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await api.post(
        ApiConstants.login,
        body: {'email': email.trim(), 'password': password},
      );

      final response = AuthResponse.fromJson(data);
      if (response.success && response.user != null && response.token != null) {
        final user = response.user!.copyWith(token: response.token);
        await storage.saveUser(user);
        api.setToken(response.token);
      }
      return response;
    }, context: 'AuthService.login');
  }

  // ===========================================================
  // REGISTER (etendu Scout)
  // ===========================================================
  Future<AuthResponse> register(RegistrationData data) async {
    return ErrorHandler.guard(() async {
      final body = data.toJson();
      // Ne pas envoyer confirmPassword
      body.remove('confirmPassword');

      final responseData = await api.post(
        ApiConstants.register,
        body: body,
      );

      final response = AuthResponse.fromJson(responseData);
      if (response.success && response.user != null && response.token != null) {
        final user = response.user!.copyWith(token: response.token);
        await storage.saveUser(user);
        api.setToken(response.token);
      }
      return response;
    }, context: 'AuthService.register');
  }

  // ===========================================================
  // LOGOUT
  // ===========================================================
  Future<void> logout() async {
    try {
      if (api.isAuthenticated) {
        await api.post(ApiConstants.logout);
      }
    } catch (_) {}
    finally {
      await storage.clearSession();
      api.clearToken();
    }
  }

  // ===========================================================
  // RESTORE SESSION
  // ===========================================================
  Future<User?> restoreSession() async {
    final user = await storage.getUser();
    if (user == null) return null;
    api.setToken(user.token);
    return user;
  }

  // ===========================================================
  // FETCH ME
  // ===========================================================
  Future<User?> fetchMe() async {
    return ErrorHandler.guard(() async {
      if (!api.isAuthenticated) return null;
      final data = await api.get(ApiConstants.me);
      final raw = data['user'] as Map<String, dynamic>?;
      if (raw == null) return null;
      final refreshed = User.fromJson({...raw, 'token': api.token});
      await storage.saveUser(refreshed);
      return refreshed;
    }, context: 'AuthService.fetchMe');
  }

  // ===========================================================
  // FORGOT PASSWORD
  // ===========================================================
  Future<void> forgotPassword(String email) async {
    return ErrorHandler.guard(() async {
      await api.post(
        ApiConstants.forgotPassword,
        body: {'email': email.trim()},
      );
    }, context: 'AuthService.forgotPassword');
  }
}
`);

// =============================================================
// 7. SERVICE : UserService (updateProfile etendu)
// =============================================================
w('lib/services/user_service.dart', `// =============================================================
// ChefUnitPlus - UserService (etendu Scout)
// =============================================================

import '../core/constants/api_constants.dart';
import '../core/constants/role_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/role_guard.dart';
import '../models/user.dart';
import '../models/user_details.dart';
import 'api_client.dart';

class UserService {
  final ApiClient api;
  UserService(this.api);

  // ===========================================================
  // LISTING
  // ===========================================================
  Future<List<User>> listAll({UserRole? filterRole}) async {
    return ErrorHandler.guard(() async {
      final data = await api.get(
        ApiConstants.users,
        query: filterRole != null ? {'role': filterRole.name} : null,
      );
      final raw = data['data'] as List? ?? data['users'] as List? ?? const [];
      return raw.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    }, context: 'UserService.listAll');
  }

  Future<List<User>> listTrainers() => listAll(filterRole: UserRole.formateur);
  Future<List<User>> listDirectors() => listAll(filterRole: UserRole.directeur);
  Future<List<User>> listLearners() => listAll(filterRole: UserRole.apprenant);

  Future<User> getById(String id) async {
    return ErrorHandler.guard(() async {
      final data = await api.get(
        ApiConstants.withId(ApiConstants.userProfile, id),
      );
      final raw = data['data'] ?? data['user'];
      return User.fromJson(raw as Map<String, dynamic>);
    }, context: 'UserService.getById');
  }

  // ===========================================================
  // FICHE COMPLETE
  // ===========================================================
  Future<Map<String, dynamic>> getFullProfile(String userId) async {
    return ErrorHandler.guard(() async {
      final data = await api.get(
        ApiConstants.withId(ApiConstants.userFullProfile, userId),
      );
      return data['data'] as Map<String, dynamic>;
    }, context: 'UserService.getFullProfile');
  }

  Future<UserDetails> updateDetails(String userId, Map<String, dynamic> fields) async {
    return ErrorHandler.guard(() async {
      final data = await api.patch(
        '/users/\$userId/details',
        body: fields,
      );
      return UserDetails.fromJson(data['data'] as Map<String, dynamic>);
    }, context: 'UserService.updateDetails');
  }

  // ===========================================================
  // MISE A JOUR PROFIL PERSONNEL
  // ===========================================================
  Future<User> updateProfile({
    String? fullName,
    String? postNom,
    String? prenom,
    String? phone,
    String? sexe,
    String? dateNaissance,
    String? lieuNaissance,
    String? photoUrl,
    Map<String, dynamic>? details,
  }) async {
    return ErrorHandler.guard(() async {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (postNom != null) body['post_nom'] = postNom;
      if (prenom != null) body['prenom'] = prenom;
      if (phone != null) body['phone'] = phone;
      if (sexe != null) body['sexe'] = sexe;
      if (dateNaissance != null) body['date_naissance'] = dateNaissance;
      if (lieuNaissance != null) body['lieu_naissance'] = lieuNaissance;
      if (photoUrl != null) body['photo_url'] = photoUrl;
      if (details != null) body['details'] = details;

      final data = await api.patch('/users/me', body: body);
      final raw = data['data'] ?? data['user'];
      return User.fromJson(raw as Map<String, dynamic>);
    }, context: 'UserService.updateProfile');
  }

  // ===========================================================
  // PROMOTION
  // ===========================================================
  Future<User> promote({
    required String userId,
    required UserRole newRole,
    required UserRole actorRole,
  }) async {
    return ErrorHandler.guard(() async {
      if (!RoleGuard.canPromoteTo(actorRole, newRole)) {
        throw AppException.forbidden('Promotion non autorisee');
      }
      final data = await api.patch(
        ApiConstants.withId(ApiConstants.promoteUser, userId),
        body: {'role': newRole.name},
      );
      return User.fromJson(data['data'] as Map<String, dynamic>);
    }, context: 'UserService.promote');
  }

  // ===========================================================
  // SUSPENSION / REACTIVATION
  // ===========================================================
  Future<void> suspend(String userId) async {
    return ErrorHandler.guard(() async {
      await api.patch(ApiConstants.withId(ApiConstants.suspendUser, userId));
    }, context: 'UserService.suspend');
  }

  Future<void> reactivate(String userId) async {
    return ErrorHandler.guard(() async {
      await api.patch(
        '\${ApiConstants.withId(ApiConstants.suspendUser, userId)}/reactivate',
      );
    }, context: 'UserService.reactivate');
  }

  // ===========================================================
  // RESET PASSWORD
  // ===========================================================
  Future<void> resetPassword({
    required String userId,
    required String newPassword,
  }) async {
    return ErrorHandler.guard(() async {
      await api.patch(
        ApiConstants.withId(ApiConstants.userResetPassword, userId),
        body: {'newPassword': newPassword},
      );
    }, context: 'UserService.resetPassword');
  }

  // ===========================================================
  // SUPPRESSION
  // ===========================================================
  Future<void> delete(String userId) async {
    return ErrorHandler.guard(() async {
      await api.delete(ApiConstants.withId(ApiConstants.userProfile, userId));
    }, context: 'UserService.delete');
  }
}
`);

console.log('');
console.log('===========================================================');
console.log('  MODELS + SERVICES PRETS !');
console.log('===========================================================');
console.log('');
console.log('Fichiers crees :');
console.log('  - lib/models/user.dart');
console.log('  - lib/models/user_details.dart');
console.log('  - lib/models/scout_camp.dart');
console.log('  - lib/models/emergency_contact.dart');
console.log('  - lib/models/registration_data.dart');
console.log('  - lib/services/auth_service.dart');
console.log('  - lib/services/user_service.dart');
console.log('');
console.log('Etape suivante : 03_flutter_register_ui.js (l\'ecran d\'inscription)');
console.log('');