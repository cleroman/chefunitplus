// =============================================================
// ChefUnitPlus - EmailWithDomainController
// Controller pour champ email avec suffixe @chefunitplus.fesco
// =============================================================
import 'package:flutter/material.dart';

class EmailWithDomainController extends TextEditingController {
  // ignore: constant_identifier_names

  static const String DOMAIN = 'chefunitplus.fesco';
  // ignore: constant_identifier_names

  static const String SUFFIX = '@$DOMAIN';

  EmailWithDomainController({String? initialValue})
      : super(text: initialValue ?? '');

  @override
  set text(String newText) {
    // Cas 1 : L'utilisateur tape @ a la fin
    if (newText.endsWith('@') && !newText.contains(SUFFIX)) {
      final username = newText.substring(0, newText.length - 1);
      if (!username.contains('@')) {
        final fullText = '$username$SUFFIX';
        super.text = fullText;
        selection = TextSelection.collapsed(offset: fullText.length);
        return;
      }
    }

    // Cas 2 : L'utilisateur essaie de modifier le suffixe
    if (text.contains(SUFFIX) && !newText.endsWith(DOMAIN)) {
      final atIndex = newText.indexOf('@');
      if (atIndex == -1) {
        final username = newText;
        super.text = username;
        selection = TextSelection.collapsed(offset: username.length);
        return;
      } else {
        final username = newText.substring(0, atIndex);
        final fullText = '$username$SUFFIX';
        super.text = fullText;
        selection = TextSelection.collapsed(offset: fullText.length);
        return;
      }
    }

    // Cas 3 : L'utilisateur a efface le @
    if (!newText.contains('@') && text.contains(SUFFIX)) {
      super.text = newText;
      selection = TextSelection.collapsed(offset: newText.length);
      return;
    }

    // Cas 4 : Comportement normal
    super.text = newText;
  }

  /// Recupere l'email complet (username@chefunitplus.fesco)
  String get fullEmail {
    final value = text.trim();
    if (value.contains('@')) return value;
    return '$value$SUFFIX';
  }

  /// Recupere juste le nom d'utilisateur
  String get username {
    final value = text.trim();
    return value.split('@').first;
  }

  /// Verifie si le champ est valide (a un @ et un suffixe)
  bool get isValid {
    final value = text.trim();
    if (!value.contains('@')) return false;
    if (!value.endsWith(SUFFIX)) return false;
    final username = value.split('@').first;
    if (username.length < 3) return false;
    if (!RegExp(r'^[a-z0-9._-]+$').hasMatch(username)) return false;
    return true;
  }
}