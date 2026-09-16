import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;
  String get code => _locale.languageCode;
  bool get isFrench => code == 'fr';
  bool get isEnglish => code == 'en';

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setLanguage(String code) {
    setLocale(Locale(code));
  }

  void toggle() {
    setLocale(Locale(isFrench ? 'en' : 'fr'));
  }
}