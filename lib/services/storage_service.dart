// =============================================================
// ChefUnitPlus - Persistance locale (SharedPreferences)
// Stocke le token, l'utilisateur, et des flags de session
// =============================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';


class StorageService {
  // ===========================================================
  // Y- CL?S
  // ===========================================================
  static const String _kToken = 'auth_token';
  static const String _kUser = 'auth_user';
  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kLastSync = 'last_sync_at';

  // ===========================================================
  // Y' SESSION UTILISATEUR
  // ===========================================================
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, user.token ?? '');
    await prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
  }

  // ===========================================================
  // Ys? ONBOARDING
  // ===========================================================
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingSeen) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
  }

  // ===========================================================
  // Y"" SYNC
  // ===========================================================
  Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastSync);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> setLastSync(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSync, time.toIso8601String());
  }

  // ===========================================================
  // Y-' RESET COMPLET
  // ===========================================================
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}