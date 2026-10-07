import 'package:flutter/material.dart';

class EmailWithDomainController extends TextEditingController {
  static const String DOMAIN = 'chefunitplus.fesco.org';
  static const String SUFFIX = '@$DOMAIN';

  EmailWithDomainController({String? initialValue})
      : super(text: initialValue ?? '');

  /// Retourne l'email complet avec le domaine.
  /// Exemple : "jean" -> "jean@chefunitplus.fesco.org"
  /// Si le texte contient deja un '@', il est renvoye tel quel.
  String get fullEmail {
    final t = text.trim();
    if (t.isEmpty) return '';
    if (t.contains('@')) return t;
    return '$t$SUFFIX';
  }

  void handleInput(String value) {
    if (value.endsWith('@') && !value.contains(SUFFIX)) {
      final username = value.substring(0, value.length - 1);
      if (!username.contains('@')) {
        final fullText = '$username$SUFFIX';
        super.text = fullText;
        selection = TextSelection.collapsed(offset: fullText.length);
        return;
      }
    }
    if (text.contains(SUFFIX) && !value.endsWith(DOMAIN)) {
      final atIndex = value.indexOf('@');
      if (atIndex == -1) {
        super.text = value;
        selection = TextSelection.collapsed(offset: value.length);
      } else {
        final username = value.substring(0, atIndex);
        final fullText = '$username$SUFFIX';
        super.text = fullText;
        selection = TextSelection.collapsed(offset: fullText.length);
      }
    }
  }

  @override
  set text(String newText) {
    if (newText.endsWith('@') && !newText.contains(SUFFIX)) {
      final username = newText.substring(0, newText.length - 1);
      if (!username.contains('@')) {
        final fullText = '$username$SUFFIX';
        super.text = fullText;
        selection = TextSelection.collapsed(offset: fullText.length);
        return;
      }
    }
    super.text = newText;
  }
}
