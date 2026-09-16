// =============================================================
// ChefUnitPlus - Validateurs de formulaires
// Toutes les validations d'input centralises
// =============================================================

import '../constants/app_strings.dart';

class Validators {
  Validators._(); // Empche l'instanciation

  // ===========================================================
  // Y" EMAIL
  // ===========================================================
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  // ===========================================================
  // Y"' MOT DE PASSE
  // ===========================================================
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  /// Mot de passe renforc (au moins 1 maj, 1 chiffre, 8 caractres)
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 8) {
      return 'Au moins 8 caractres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Doit contenir au moins 1 majuscule';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Doit contenir au moins 1 chiffre';
    }
    return null;
  }

  // ===========================================================
  // o. CONFIRMATION DE MOT DE PASSE
  // ===========================================================
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value != original) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  // ===========================================================
  // Y"z T?L?PHONE
  // ===========================================================
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    // Retire espaces et tirets
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');

    // Format international : +243XXXXXXXXX ou 243XXXXXXXXX
    if (cleaned.startsWith('+')) {
      final digits = cleaned.substring(1);
      if (digits.length < 10 || digits.length > 15) {
        return AppStrings.invalidPhone;
      }
      return null;
    }

    // Format local : 089XXXXXXX
    if (cleaned.length >= 9 && cleaned.length <= 15) {
      return null;
    }

    return AppStrings.invalidPhone;
  }

  /// Tlphone mobile money (RDC : commence par 243 ou 0)
  static String? mobileMoneyPhone(String? value) {
    final basic = phone(value);
    if (basic != null) return basic;

    final cleaned = value!.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!cleaned.startsWith('243') &&
        !cleaned.startsWith('+243') &&
        !cleaned.startsWith('0')) {
      return 'Numro doit commencer par 243 ou 0';
    }
    return null;
  }

  // ===========================================================
  // Y' NOM
  // ===========================================================
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 3) {
      return 'Nom trop court (min. 3 caractres)';
    }
    if (value.trim().length > 100) {
      return 'Nom trop long (max. 100 caractres)';
    }
    return null;
  }

  // ===========================================================
  // Y" CHAMPS NUM?RIQUES
  // ===========================================================
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Le champ "$fieldName" est obligatoire'
          : AppStrings.fieldRequired;
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Montant'}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return '$fieldName doit tre un nombre';
    }
    if (parsed <= 0) {
      return '$fieldName doit tre suprieur  0';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? label}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < min) {
      return '${label ?? 'Minimum'} : $min caractres requis';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? label}) {
    if (value != null && value.length > max) {
      return '${label ?? 'Maximum'} : $max caractres autoriss';
    }
    return null;
  }

  // ===========================================================
  // YO URL
  // ===========================================================
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final regex = RegExp(
      r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-._~:/?#[\]@!$&()*+,;=]*)?$',
    );
    if (!regex.hasMatch(value.trim())) {
      return 'URL invalide';
    }
    return null;
  }

  // ===========================================================
  // Y' PRIX
  // ===========================================================
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Prix invalide';
    }
    if (parsed < 0) {
      return 'Le prix ne peut pas tre ngatif';
    }
    if (parsed > 100000) {
      return 'Le prix semble trop lev (max. 100 000)';
    }
    return null;
  }

  // ===========================================================
  // Y COMBINATEUR
  // ===========================================================
  /// Combine plusieurs validateurs en chane
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}