// =============================================================
// ChefUnitPlus - Routeur central
// AppRoutes vient de app_routes.dart (ne pas redefinir ici)
// =============================================================

import 'package:flutter/material.dart';

import '../../views/splash/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/forgot_password_screen.dart';

import '../../views/admin/admin_dashboard.dart';
import '../../views/admin/users_management_screen.dart';
import '../../views/admin/global_stats_screen.dart';
import '../../views/admin/payments_log_screen.dart';
import '../../views/admin/system_settings_screen.dart';
import '../../views/admin/complaints_screen.dart';
import '../../views/admin/password_requests_screen.dart';
import '../../views/admin/scout_groups_screen.dart';
import '../../views/learner/profile_screen.dart';
import '../../views/learner/edit_profile_screen.dart';

import '../../views/director/director_dashboard.dart';
import '../../views/director/formation_editor_screen.dart';
import '../../views/director/enrollments_validation_screen.dart';
import '../../views/director/trainers_management_screen.dart';
import '../../views/director/module_assign_screen.dart';
import '../../views/director/formation_stats_screen.dart';
import '../../views/director/director_module_validation_screen.dart';

import '../../views/mobile/trainer/trainer_dashboard.dart';
import '../../views/mobile/trainer/my_modules_screen.dart';
import '../../views/mobile/trainer/students_list_screen.dart';
import '../../views/mobile/trainer/trainer_create_module_screen.dart';

import '../../views/learner/learner_dashboard.dart';
import '../../views/learner/formation_catalog_screen.dart';
import '../../views/learner/my_enrollments_screen.dart';
import '../../views/learner/certificate_screen.dart';

import '../../views/director/director_formations_list_screen.dart';
import '../../views/learner/learner_payment_list_screen.dart';
import '../../views/learner/learner_payment_screen.dart';
import '../../views/learner/formation_detail_screen.dart';
import '../../views/learner/otp_input_screen.dart';
import '../../views/learner/receipt_screen.dart';
import '../../views/learner/my_qr_codes_screen.dart';
import '../../views/learner/learner_formation_suivi_screen.dart';
import 'app_routes.dart';
import '../../views/mobile/shared/scout_videos_screen.dart';
import '../../views/shared/notifications_screen.dart';
import '../../views/shared/messages_screen.dart';
import '../../views/mobile/shared/settings_screen.dart';
import '../../views/shared/change_password_screen.dart';
import '../layout_detector.dart';
import '../../views/web/web_director_dashboard.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';

    switch (name) {
      // ---------------- SPLASH ----------------
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);

      // ---------------- AUTH ----------------
      case AppRoutes.login:
        return _page(const LoginScreen(), settings);
      case AppRoutes.forgotPassword:
        return _page(const ForgotPasswordScreen(), settings);

      case AppRoutes.register:
        return _page(const RegisterScreen(), settings);

      // ---------------- HOME PAR ROLE ----------------
      case AppRoutes.adminHome:
        return _page(const AdminDashboard(), settings);
      case AppRoutes.directorHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LayoutDetector(
            webChild: WebDirectorDashboard(),
            mobileChild: DirectorDashboard(),
          ),
        );
      case AppRoutes.trainerHome:
        return _page(const TrainerDashboard(), settings);
      case AppRoutes.learnerHome:
        return _page(const LearnerDashboard(), settings);

      // ---------------- LEARNER ----------------
      case AppRoutes.learnerCatalog:
        return _page(const FormationCatalogScreen(), settings);
      case AppRoutes.learnerEnrollments:
      case '/learner/enrollments':
        return _page(const MyEnrollmentsScreen(), settings);
      case AppRoutes.learnerCertificates:
        return _page(const CertificateScreen(), settings);
      // ============================================================
      // ROUTES APPRENANT
      // ============================================================
      
      case '/learner/catalog':
        return _page(const FormationCatalogScreen(), settings);
      
      case '/learner/certificates':
        return _page(const CertificateScreen(), settings);
      
      case '/learner/profile':
        return _page(const ProfileScreen(), settings);
      
      case '/learner/messages':
        return _page(const MessagesScreen(), settings);
      
      case '/learner/qr-codes':
        return _page(const MyQrCodesScreen(), settings);      
      case '/learner/payment':
        return _page(const LearnerPaymentListScreen(), settings);
      

      case AppRoutes.learnerProfile:
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      // ---------------- DIRECTOR ----------------
      case AppRoutes.directorFormationEditor:
        return _page(const FormationEditorScreen(), settings);
      case AppRoutes.directorEnrollments:
        return _page(const EnrollmentsValidationScreen(), settings);
      case AppRoutes.directorTrainers:
        return _page(const TrainersManagementScreen(), settings);
      case AppRoutes.directorModuleAssign:
        return _page(const ModuleAssignScreen(), settings);
      case AppRoutes.directorStats:
        return _page(const FormationStatsScreen(), settings);

      // ---------------- TRAINER ----------------
      case AppRoutes.trainerModules:
      case '/trainer/modules':
        return _page(const MyModulesScreen(), settings);
      case AppRoutes.trainerStudents:
        return _page(const StudentsListScreen(), settings);
      case '/trainer/module/create':
        return _page(const TrainerCreateModuleScreen(), settings);

      // ---------------- ADMIN ----------------
      case AppRoutes.adminUsers:
        return _page(const UsersManagementScreen(), settings);
      case AppRoutes.adminStats:
        return _page(const GlobalStatsScreen(), settings);
      case AppRoutes.adminPayments:
        return _page(const PaymentsLogScreen(), settings);
      case AppRoutes.adminSettings:
        return _page(const SystemSettingsScreen(), settings);
      case AppRoutes.adminComplaints:
        return _page(const ComplaintsScreen(), settings);
      case AppRoutes.adminScoutGroups:
        return _page(const ScoutGroupsScreen(), settings);

      case AppRoutes.adminPasswordRequests:
        return _page(const PasswordRequestsScreen(), settings);

      case AppRoutes.profile:
      case '/profile':
        return _page(const ProfileScreen(), settings);

      // ---------------- COMMUNS ----------------
      case AppRoutes.scoutVideos:
      case '/scout-videos':
        return _page(const ScoutVideosScreen(), settings);
      case AppRoutes.notifications:
      case '/directeur/formations':
      case '/director/formations':
        return _page(const DirectorFormationsListScreen(), settings);

      case '/notifications':
        return _page(const NotificationsScreen(), settings);
      case AppRoutes.settings:
      case '/settings':
        return _page(const SettingsScreen(), settings);
      case '/messages':
        return _page(const MessagesScreen(), settings);
      case '/change-password':
        return _page(const ChangePasswordScreen(), settings);
      case '/director/modules/validation':
        return _page(const DirectorModuleValidationScreen(), settings);

      // ---------------- INCONNUE ----------------
      default:
        return _unknown(name, settings);
    }
  }

  static MaterialPageRoute _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }

  static MaterialPageRoute _unknown(String name, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Page introuvable'),
          backgroundColor: const Color(0xFFC62828),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 80, color: Color(0xFFC62828)),
                const SizedBox(height: 16),
                const Text(
                  'Page introuvable',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucune route definie pour :\n"$name"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6E6A72)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}