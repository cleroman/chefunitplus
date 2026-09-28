// ============================================================
// ChefUnitPlus - DirectorPageHeader
// Header gradient mauve reutilisable pour tous les ecrans Directeur
// ============================================================

import 'package:flutter/material.dart';
import 'director_theme_adapter.dart';

class DirectorPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final bool showBack;

  const DirectorPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        DirectorThemeAdapter.gapLg,
        DirectorThemeAdapter.gapLg,
        DirectorThemeAdapter.gapLg,
        DirectorThemeAdapter.gapMd,
      ),
      decoration: DirectorThemeAdapter.headerDecoration(),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Retour',
            ),
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusSm),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: DirectorThemeAdapter.gapMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
