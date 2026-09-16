// =============================================================
// ChefUnitPlus - Constantes API
// Centralise toutes les URLs, tokens et endpoints de l'application
// =============================================================

class ApiConstants {
  ApiConstants._(); // Empfche l'instanciation

  // -----------------------------------------------------------
  // BACKEND PRINCIPAL
  // -----------------------------------------------------------
  static const String baseUrl = 'http://localhost:3000';
  static const String apiVersion = '/api';
  static const String apiUrl = '$baseUrl$apiVersion';

  // Timeouts (en secondes)
  static const int connectTimeout = 15;
  static const int receiveTimeout = 20;

  // -----------------------------------------------------------
  // AUTHENTIFICATION
  // -----------------------------------------------------------
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';

  // -----------------------------------------------------------
  // UTILISATEURS & Rf?LES
  // -----------------------------------------------------------
  static const String users = '/users';
  static const String promoteUser = '/users/{id}/promote';   // PATCH
  static const String suspendUser = '/users/{id}/suspend';   // PATCH
  static const String userProfile = '/users/{id}';

  // -----------------------------------------------------------
  // FORMATIONS
  // -----------------------------------------------------------
  static const String formations = '/formations';
  static const String formationById = '/formations/{id}';
  static const String formationsByDirector = '/formations/director/me';
  static const String publishFormation = '/formations/{id}/publish';

  // -----------------------------------------------------------
  // MODULES
  // -----------------------------------------------------------
  static const String modules = '/modules';
  static const String modulesByFormation = '/formations/{id}/modules';
  static const String assignTrainer = '/modules/{id}/assign';   // PATCH

  // -----------------------------------------------------------
  // LEf?ONS
  // -----------------------------------------------------------
  static const String lessons = '/lessons';
  static const String lessonsByModule = '/modules/{id}/lessons';

  // -----------------------------------------------------------
  // INSCRIPTIONS
  // -----------------------------------------------------------
  static const String enrollments = '/enrollments';
  static const String myEnrollments = '/enrollments/me';
  static const String pendingEnrollments = '/enrollments/pending';
  static const String validateEnrollment = '/enrollments/{id}/validate';
  static const String rejectEnrollment = '/enrollments/{id}/reject';

  // -----------------------------------------------------------

  // -----------------------------------------------------------
  // SCOUT GROUPS
  // -----------------------------------------------------------
  static const String scoutGroups = '/scout-groups';
  static const String scoutGroupById = '/scout-groups/{id}';
  static const String assignDirector = '/scout-groups/{id}/assign-director';

  // -----------------------------------------------------------
  // COMPLAINTS (plaintes)
  // -----------------------------------------------------------
  static const String complaints = '/complaints';
  static const String myComplaints = '/complaints/me';
  static const String respondComplaint = '/complaints/{id}/respond';
  static const String closeComplaint = '/complaints/{id}/close';

  // -----------------------------------------------------------
  // PASSWORD REQUESTS
  // -----------------------------------------------------------
  static const String passwordRequests = '/password-requests';
  static const String approvePasswordRequest = '/password-requests/{id}/approve';
  static const String rejectPasswordRequest = '/password-requests/{id}/reject';

  // -----------------------------------------------------------
  // USER ACTIONS (Admin)
  // -----------------------------------------------------------
  static const String userFullProfile = '/users/{id}/full-profile';
  static const String userResetPassword = '/users/{id}/reset-password';

  // PAIEMENTS (FlexPaie)
  // -----------------------------------------------------------
  static const String flexPaieBaseUrl = 'https://api.flexpaie.com/v1';
  static const String flexPaieToken = 'VOTRE_TOKEN_API_FLEXPAIE';
  static const String flexPaieMerchant = 'VOTRE_CODE_MARCHAND';
  static const String flexPaieInitiate = '/payment/request';
  static const String flexPaieCheck = '/payment/check/{orderNumber}';

  // -----------------------------------------------------------
  // CERTIFICATS
  // -----------------------------------------------------------
  static const String certificates = '/certificates';
  static const String myCertificates = '/certificates/me';

  // -----------------------------------------------------------
  // STATISTIQUES
  // -----------------------------------------------------------
  static const String statsGlobal = '/stats/global';
  static const String statsDirector = '/stats/director';
  static const String statsTrainer = '/stats/trainer';

  // -----------------------------------------------------------
  // HEADERS
  // -----------------------------------------------------------
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // -----------------------------------------------------------
  // HELPER : remplace {id} / {orderNumber} dans un endpoint
  // -----------------------------------------------------------
  static String withId(String endpoint, String id) =>
      endpoint.replaceAll('{id}', id);

  static String withOrderNumber(String endpoint, String orderNumber) =>
      endpoint.replaceAll('{orderNumber}', orderNumber);
}