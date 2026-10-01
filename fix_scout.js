// =============================================================
// ChefUnitPlus - Fix complet Scout (AuthController + Register + Router)
// Version corrigee avec $$ echappes
// =============================================================

const fs = require('fs');
const path = require('path');

const BASE = process.cwd();

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Fix Scout');
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
// 1. AUTH CONTROLLER (adapte a RegistrationData)
// =============================================================
w('lib/controllers/auth_controller.dart', `// =============================================================
// ChefUnitPlus - AuthController
// =============================================================

import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../models/auth_response.dart';
import '../models/registration_data.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  final AuthService _service;

  AuthController({required AuthService service}) : _service = service;

  AuthState _state = AuthState.unknown;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ===========================================================
  // BOOTSTRAP
  // ===========================================================
  Future<void> bootstrap() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _service.restoreSession();
      if (user != null) {
        _currentUser = user;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e, st) {
      ErrorHandler.log(e, st, 'AuthController.bootstrap');
      _state = AuthState.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // LOGIN
  // ===========================================================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.login(email: email, password: password);
      return _handle(response);
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'AuthController.login');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // REGISTER (accepte RegistrationData complet)
  // ===========================================================
  Future<bool> register(RegistrationData data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.register(data);
      return _handle(response);
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'AuthController.register');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // LOGOUT
  // ===========================================================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.logout();
    } catch (e) {
      // Ignorer
    }

    _currentUser = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // ===========================================================
  // REFRESH
  // ===========================================================
  Future<void> refreshUser() async {
    try {
      final user = await _service.fetchMe();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e, st) {
      ErrorHandler.log(e, st, 'AuthController.refreshUser');
    }
  }

  // ===========================================================
  // FORGOT PASSWORD
  // ===========================================================
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.forgotPassword(email);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.message(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // HELPERS
  // ===========================================================
  bool _handle(AuthResponse response) {
    if (response.success && response.user != null) {
      _currentUser = response.user;
      _state = AuthState.authenticated;
      return true;
    }
    _errorMessage = response.message ?? 'Authentification echouee';
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
`);

// =============================================================
// 2. APP ROUTER (avec _unknownRoute corrige)
// =============================================================
w('lib/core/routes/app_router.dart', `// =============================================================
// ChefUnitPlus - Routeur central
// =============================================================

import 'package:flutter/material.dart';

import '../constants/role_constants.dart';
import '../../models/user.dart';
import 'app_routes.dart';

// Screens
import '../../views/splash/splash_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/common/role_router.dart';
import '../../views/learner/formation_detail_screen.dart';
import '../../views/learner/lesson_player_screen.dart';
import '../../views/admin/scout_groups_screen.dart';
import '../../views/admin/complaints_screen.dart';
import '../../views/admin/password_requests_screen.dart';
import '../../views/admin/user_details_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/profile/edit_profile_screen.dart';

// =============================================================
// GUARD
// =============================================================
class RoleGuard {
  RoleGuard._();

  static bool check({
    required BuildContext context,
    required User? currentUser,
    required List<UserRole> allowed,
    bool showMessage = true,
  }) {
    if (currentUser == null) {
      if (showMessage) _show(context, 'Vous devez etre connecte');
      return false;
    }
    if (!allowed.contains(currentUser.role)) {
      if (showMessage) _show(context, 'Acces non autorise');
      return false;
    }
    if (!currentUser.isActive) {
      if (showMessage) _show(context, 'Compte suspendu');
      return false;
    }
    return true;
  }

  static void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }
}

// =============================================================
// ROUTEUR
// =============================================================
class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';

    // Routes parametrees
    if (name.startsWith('\\\${AppRoutes.learnerFormationDetail}/')) {
      final id = name.split('/').last;
      return _route(FormationDetailScreen(formationId: id), settings);
    }
    if (name.startsWith('\\\${AppRoutes.learnerLessonPlayer}/')) {
      final id = name.split('/').last;
      return _route(LessonPlayerScreen(lessonId: id), settings);
    }

    switch (name) {
      // --- Demarrage ---
      case AppRoutes.splash:
        return _route(const SplashScreen(), settings);
      case AppRoutes.onboarding:
        return _route(const OnboardingScreen(), settings);

      // --- Auth ---
      case AppRoutes.login:
        return _route(const LoginScreen(), settings);
      case AppRoutes.register:
        return _route(const RegisterScreen(), settings);
      case AppRoutes.forgotPassword:
        return _route(const ForgotPasswordScreen(), settings);

      // --- Home ---
      case AppRoutes.adminHome:
      case AppRoutes.directorHome:
      case AppRoutes.trainerHome:
      case AppRoutes.learnerHome:
        return _route(const RoleRouter(), settings);

      // --- Profil ---
      case AppRoutes.profile:
        return _route(const ProfileScreen(), settings);
      case AppRoutes.editProfile:
        return _route(const EditProfileScreen(), settings);

      // --- Admin Scout ---
      case AppRoutes.adminScoutGroups:
        return _route(const ScoutGroupsScreen(), settings);
      case AppRoutes.adminComplaints:
        return _route(const ComplaintsScreen(), settings);
      case AppRoutes.adminPasswordRequests:
        return _route(const PasswordRequestsScreen(), settings);

      default:
        return _unknownRoute(settings);
    }
  }

  static Widget homeFor(User user) {
    return const RoleRouter();
  }

  static String homeRouteName(User user) {
    switch (user.role) {
      case UserRole.admin:
        return AppRoutes.adminHome;
      case UserRole.directeur:
        return AppRoutes.directorHome;
      case UserRole.formateur:
        return AppRoutes.trainerHome;
      case UserRole.apprenant:
        return AppRoutes.learnerHome;
    }
  }

  static MaterialPageRoute _route(Widget screen, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => screen,
      settings: settings,
    );
  }

  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Page introuvable'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Route inconnue',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  settings.name ?? 'inconnue',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      settings: settings,
    );
  }
}
`);

console.log('');
console.log('===========================================================');
console.log('  FIX APPLIQUE !');
console.log('===========================================================');
console.log('');
console.log('Fichiers corriges :');
console.log('  - lib/controllers/auth_controller.dart');
console.log('  - lib/core/routes/app_router.dart');
console.log('');