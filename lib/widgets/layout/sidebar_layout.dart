import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Item de la sidebar laterale.
class SidebarItem {
  final IconData icon;
  final String label;
  final String route;
  final int badge;
  final VoidCallback? onTap;
  const SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge = 0,
    this.onTap,
  });
}

/// Layout avec sidebar persistante a gauche (desktop) et drawer (mobile).
///
/// Utilisation :
/// ```dart
/// SidebarLayout(
///   title: 'Administration',
///   currentRoute: AppRoutes.adminHome,
///   items: [...],
///   body: MyScreenContent(),
/// )
/// ```
class SidebarLayout extends StatelessWidget {
  final String title;
  final String currentRoute;
  final List<SidebarItem> items;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;

  const SidebarLayout({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.items,
    required this.body,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Sur mobile : drawer classique (avec bouton hamburger)
      drawer: isDesktop ? null : _Sidebar(items: items, currentRoute: currentRoute),
      appBar: AppBar(
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        // Bouton retour si demande explicitement, sinon hamburger auto
        automaticallyImplyLeading: showBackButton || !isDesktop,
        leading: showBackButton && isDesktop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(title),
        actions: actions,
      ),
      body: isDesktop
          ? Row(
              children: [
                _Sidebar(items: items, currentRoute: currentRoute, fixed: true),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}

/// La sidebar elle-meme (utilisee fixe sur desktop, en Drawer sur mobile).
class _Sidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final String currentRoute;
  final bool fixed;
  const _Sidebar({
    required this.items,
    required this.currentRoute,
    this.fixed = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mauve, AppColors.kaki],
              ),
            ),
            child: const Text(
              'ChefUnitPlus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.map((it) => _SidebarTile(item: it, currentRoute: currentRoute)).toList(),
            ),
          ),
        ],
      ),
    );

    if (fixed) {
      return SizedBox(width: 260, child: content);
    }
    return Drawer(child: content);
  }
}

class _SidebarTile extends StatelessWidget {
  final SidebarItem item;
  final String currentRoute;
  const _SidebarTile({required this.item, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isSelected = item.route == currentRoute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.mauve.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Icon(
            item.icon,
            color: isSelected ? AppColors.mauve : AppColors.textMuted,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              color: isSelected ? AppColors.mauve : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: item.badge > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.badge}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
          onTap: () {
            // Ferme le drawer sur mobile
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            // Navigue si different
            if (item.onTap != null) {
              item.onTap!();
            } else if (item.route != currentRoute) {
              Navigator.of(context).pushReplacementNamed(item.route);
            }
          },
        ),
      ),
    );
  }
}