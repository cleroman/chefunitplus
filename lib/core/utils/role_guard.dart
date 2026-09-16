// =============================================================
// ChefUnitPlus - Vérification des permissions par rôle
// À utiliser dans la logique métier (controllers, services)
// Pour les guards UI, voir app_router.dart (RoleGuard)
// =============================================================

import '../constants/role_constants.dart';

class RoleGuard {
  RoleGuard._(); // Empêche l'instanciation

  // ===========================================================
  // 🎯 VÉRIFICATION GÉNÉRIQUE
  // ===========================================================

  /// Vérifie si un rôle appartient à une liste autorisée
  static bool hasRole(UserRole? role, List<UserRole> allowed) {
    if (role == null) return false;
    return allowed.contains(role);
  }

  /// Vérifie si un rôle a AU MOINS le niveau requis
  static bool hasMinimumRole(UserRole? role, UserRole minimum) {
    if (role == null) return false;
    return role.isAtLeast(minimum);
  }

  // ===========================================================
  // 📚 FORMATIONS
  // ===========================================================
  static bool canCreateFormation(UserRole? role) =>
      role != null && role.canCreateFormation;

  static bool canEditFormation(UserRole? role) =>
      role != null && role.canEditFormation;

  static bool canDeleteFormation(UserRole? role) =>
      role == UserRole.directeur || role == UserRole.admin;

  static bool canPublishFormation(UserRole? role) =>
      role == UserRole.directeur || role == UserRole.admin;

  // ===========================================================
  // 📦 MODULES & LEÇONS
  // ===========================================================
  static bool canCreateModule(UserRole? role) =>
      role != null && role.canCreateModule;

  static bool canEditModule(UserRole? role) =>
      role != null && role.canEditModule;

  static bool canDeleteModule(UserRole? role) =>
      role == UserRole.directeur || role == UserRole.admin;

  static bool canAssignTrainer(UserRole? role) =>
      role != null && role.canAssignTrainer;

  static bool canCreateLesson(UserRole? role) =>
      role != null && role.canEditLesson;

  static bool canEditLesson(UserRole? role) =>
      role != null && role.canEditLesson;

  // ===========================================================
  // 📝 INSCRIPTIONS
  // ===========================================================
  static bool canEnroll(UserRole? role) =>
      role != null && role.canEnrollInFormation;

  static bool canPayForFormation(UserRole? role) =>
      role != null && role.canPayForFormation;

  static bool canValidateEnrollment(UserRole? role) =>
      role != null && role.canValidateEnrollment;

  static bool canRejectEnrollment(UserRole? role) =>
      role != null && role.canRejectEnrollment;

  // ===========================================================
  // 👥 UTILISATEURS
  // ===========================================================
  static bool canPromoteUser(UserRole? role) =>
      role != null && role.canPromoteUser;

  static bool canPromoteTo(UserRole? actor, UserRole target) {
    if (actor == null) return false;
    return actor.canPromoteTo(target);
  }

  static bool canSuspendUser(UserRole? role) =>
      role != null && role.canSuspendUser;

  static bool canAccessAllUsers(UserRole? role) =>
      role != null && role.canAccessAllUsers;

  /// Peut voir le détail d'un autre utilisateur
  static bool canViewUser(UserRole? actor, UserRole target) {
    if (actor == null) return false;
    if (actor == UserRole.admin) return true;
    if (actor == UserRole.directeur) {
      // Directeur voit les apprenants et formateurs
      return target == UserRole.apprenant || target == UserRole.formateur;
    }
    if (actor == UserRole.formateur) {
      // Formateur voit uniquement les apprenants de ses modules
      return target == UserRole.apprenant;
    }
    return false;
  }

  // ===========================================================
  // 📊 STATISTIQUES
  // ===========================================================
  static bool canViewGlobalStats(UserRole? role) =>
      role != null && role.canViewGlobalStats;

  static bool canViewDirectorStats(UserRole? role) =>
      role != null && role.canViewDirectorStats;

  static bool canViewTrainerStats(UserRole? role) =>
      role != null && role.canViewTrainerStats;

  // ===========================================================
  // 💳 PAIEMENTS
  // ===========================================================
  static bool canViewPaymentsLog(UserRole? role) =>
      role == UserRole.admin;

  static bool canRefundPayment(UserRole? role) =>
      role == UserRole.admin;

  // ===========================================================
  // 🎓 CERTIFICATS
  // ===========================================================
  static bool canGenerateCertificate(UserRole? role) =>
      role == UserRole.directeur ||
      role == UserRole.formateur ||
      role == UserRole.admin;

  static bool canRevokeCertificate(UserRole? role) =>
      role == UserRole.admin;

  // ===========================================================
  // ⚙️ SYSTÈME
  // ===========================================================
  static bool canAccessSystemSettings(UserRole? role) =>
      role == UserRole.admin;

  static bool canManageAdmins(UserRole? role) =>
      role == UserRole.admin;

  // ===========================================================
  // 🧭 LABEL D'ACTION DÉTAILLÉ
  // ===========================================================
  /// Retourne une description textuelle de ce qu'un rôle peut faire
  static String describePermissions(UserRole? role) {
    if (role == null) return 'Aucun accès';

    final permissions = <String>[];
    if (canCreateFormation(role)) permissions.add('Créer des formations');
    if (canValidateEnrollment(role)) permissions.add('Valider les inscriptions');
    if (canAssignTrainer(role)) permissions.add('Affecter des formateurs');
    if (canEditLesson(role)) permissions.add('Éditer les leçons');
    if (canPromoteUser(role)) permissions.add('Promouvoir des utilisateurs');
    if (canAccessSystemSettings(role)) permissions.add('Administrer le système');

    if (permissions.isEmpty) return 'Accès standard';
    return permissions.join(' · ');
  }

  // ===========================================================
  // 🎭 RÔLES PROMOUVABLES
  // ===========================================================
  static List<UserRole> promotableBy(UserRole? actor) {
    if (actor == null) return const [];
    return actor.promotableRoles();
  }
}