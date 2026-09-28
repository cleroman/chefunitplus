// =============================================================
// ChefUnitPlus - LayoutDetector
// Detecte Web vs Mobile et retourne le bon widget.
// =============================================================

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class LayoutDetector extends StatelessWidget {
  final Widget webChild;
  final Widget mobileChild;

  const LayoutDetector({
    super.key,
    required this.webChild,
    required this.mobileChild,
  });

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? webChild : mobileChild;
  }
}

// Helper : verifier si on est sur Web
bool get isWeb => kIsWeb;

// Helpers : tailles d'ecran
bool isLargeScreen(BuildContext context) =>
    MediaQuery.of(context).size.width >= 900;

bool isMediumScreen(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return w >= 600 && w < 900;
}

bool isSmallScreen(BuildContext context) =>
    MediaQuery.of(context).size.width < 600;