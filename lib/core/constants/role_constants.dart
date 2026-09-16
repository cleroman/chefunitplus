// =============================================================
// ChefUnitPlus - Roles utilisateur
// =============================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

enum UserRole {
  apprenant,
  formateur,
  directeur,
  admin,
}

extension UserRoleExtension on UserRole {
  // ---------------- LABEL ----------------
  String get label {
    switch (this) {
      case UserRole.apprenant:
        return 'Apprenant';
      case UserRole.formateur:
        return 'Formateur';
      case UserRole.directeur:
        return 'Directeur';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  // ---------------- DESCRIPTION ----------------
  String get description {
    switch (this) {
      case UserRole.apprenant:
        return 'Suit les formations et paie via FlexPaie';
      case UserRole.formateur:
        return 'Cree et anime les modules de formation';
      case UserRole.directeur:
        return 'Gere les formations, formateurs et inscriptions';
      case UserRole.admin:
        return 'Administre toute la plateforme';
    }
  }

  // ---------------- ICON ----------------
  IconData get icon {
    switch (this) {
      case UserRole.apprenant:
        return Icons.school_outlined;
      case UserRole.formateur:
        return Icons.cast_for_education_outlined;
      case UserRole.directeur:
        return Icons.business_center_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  // ---------------- NIVEAU HIERARCHIQUE ----------------
  int get level {
    switch (this) {
      case UserRole.apprenant:
        return 1;
      case UserRole.formateur:
        return 2;
      case UserRole.directeur:
        return 3;
      case UserRole.admin:
        return 4;
    }
  }

  // ---------------- COMPARAISON ----------------
  bool isHigherThan(UserRole other) => level > other.level;
  bool isLowerThan(UserRole other) => level < other.level;
  bool isAtLeast(UserRole other) => level >= other.level;

  // ---------------- PROMOTION ----------------
  bool canPromoteTo(UserRole target) {
    if (this == UserRole.admin) return target != UserRole.admin;
    if (this == UserRole.directeur) return target == UserRole.formateur;
    return false;
  }

  // ---------------- PERMISSIONS METIER ----------------
  bool get canCreateFormation =>
      this == UserRole.directeur || this == UserRole.admin;
  bool get canEditFormation =>
      this == UserRole.directeur || this == UserRole.admin;
  bool get canCreateModule =>
      this == UserRole.formateur ||
      this == UserRole.directeur ||
      this == UserRole.admin;
  bool get canEditModule =>
      this == UserRole.formateur ||
      this == UserRole.directeur ||
      this == UserRole.admin;
  bool get canEditLesson =>
      this == UserRole.formateur ||
      this == UserRole.directeur ||
      this == UserRole.admin;
  bool get canValidateEnrollment =>
      this == UserRole.directeur || this == UserRole.admin;
  bool get canRejectEnrollment =>
      this == UserRole.directeur || this == UserRole.admin;
  bool get canAssignTrainer =>
      this == UserRole.directeur || this == UserRole.admin;
  bool get canPromoteUser =>
      this == UserRole.directeur || this == UserRole.admin;
  bool get canSuspendUser => this == UserRole.admin;
  bool get canAccessAllUsers => this == UserRole.admin;
  bool get canViewGlobalStats => this == UserRole.admin;
  bool get canViewDirectorStats =>
      this == UserRole.directeur || this == UserRole.admin;
  bool get canViewTrainerStats =>
      this == UserRole.formateur ||
      this == UserRole.directeur ||
      this == UserRole.admin;
  bool get canEnrollInFormation => true;
  bool get canPayForFormation => true;

  // ---------------- PROMOTABLE ROLES ----------------
  List<UserRole> promotableRoles() {
    if (this == UserRole.admin) {
      return [UserRole.directeur, UserRole.formateur];
    }
    if (this == UserRole.directeur) {
      return [UserRole.formateur];
    }
    return const [];
  }
  // ---------------- COULEUR (associee au role) ----------------
  Color get color {
    switch (this) {
      case UserRole.apprenant:
        return AppColors.textMuted;
      case UserRole.formateur:
        return AppColors.success;
      case UserRole.directeur:
        return AppColors.kaki;
      case UserRole.admin:
        return AppColors.mauve;
    }
  }
  // ---------------- FROM STRING ----------------
  static UserRole fromString(String? value) {
    if (value == null) return UserRole.apprenant;
    final v = value.toLowerCase();
    if (v == 'admin' || v == 'administrateur') return UserRole.admin;
    if (v == 'directeur' || v == 'director') return UserRole.directeur;
    if (v == 'formateur' || v == 'trainer') return UserRole.formateur;
    return UserRole.apprenant;
  }
}