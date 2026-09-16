// =============================================================
// ChefUnitPlus - Tailles, espacements, rayons, dures
// =============================================================


class AppSizes {
  AppSizes._(); // Empche l'instanciation

  // -----------------------------------------------------------
  // Y" ESPACEMENTS (padding / margin)
  // -----------------------------------------------------------
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;

  // -----------------------------------------------------------
  // Y" RAYONS DE BORDURE
  // -----------------------------------------------------------
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusCircle = 999.0;

  // -----------------------------------------------------------
  // Y HAUTEURS / LARGEURS STANDARDS
  // -----------------------------------------------------------
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 64.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 80.0;
  static const double cardElevation = 2.0;

  // -----------------------------------------------------------
  // Y" TAILLES DE POLICE
  // -----------------------------------------------------------
  static const double fontXs  = 11.0;
  static const double fontSm  = 13.0;
  static const double fontMd  = 15.0;
  static const double fontLg  = 17.0;
  static const double fontXl  = 20.0;
  static const double fontXxl = 24.0;
  static const double fontDisplay = 32.0;

  // -----------------------------------------------------------
  // Y" MARGES D'?CRAN
  // -----------------------------------------------------------
  static const double screenPadding = 20.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;

  // -----------------------------------------------------------
  //  DUR?ES D'ANIMATION
  // -----------------------------------------------------------
  static const Duration animFast   = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow   = Duration(milliseconds: 500);

  // -----------------------------------------------------------
  //  POLLING PAIEMENT
  // -----------------------------------------------------------
  static const Duration paymentPollInterval = Duration(seconds: 5);
  static const int paymentMaxAttempts = 24; // ~2 minutes

  // -----------------------------------------------------------
  // Y" BREAKPOINTS RESPONSIVE
  // -----------------------------------------------------------
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;
}