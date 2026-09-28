// =============================================================
// ChefUnitPlus - Widget AppLogo
// Logo reutilisable dans toute l'application
// =============================================================

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school,
                size: size * 0.6,
                color: Colors.grey,
              ),
            );
          },
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'ChefUnitPlus',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w800,
              color: textColor ?? Theme.of(context).primaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

// Version compacte pour l'AppBar
class AppLogoSmall extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const AppLogoSmall({
    super.key,
    this.size = 32,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      padding: EdgeInsets.all(size * 0.1),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.school, size: size * 0.7, color: Colors.white);
        },
      ),
    );
  }
}