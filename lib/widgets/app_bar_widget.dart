// =============================================================
// ChefUnitPlus - AppBarWidget
// AppBar harmonisee avec logo pour toute l'application
// =============================================================

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'app_logo.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final bool showMenuButton;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const AppBarWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showLogo = true,
    this.showBackButton = false,
    this.onBackPressed,
    this.onMenuPressed,
    this.showMenuButton = false,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        (bottom?.preferredSize.height ?? 0) + kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.mauve;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: showMenuButton
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuPressed ??
                  () => Scaffold.of(context).openDrawer(),
            )
          : showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null,
      title: Row(
        children: [
          if (showLogo) ...[
            const AppLogoSmall(size: 36),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}