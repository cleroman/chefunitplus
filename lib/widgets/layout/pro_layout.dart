import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Item de menu avec icone + label + couleur + badge.
class ProMenuItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final int badge;
  final VoidCallback? onTap;

  const ProMenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    this.badge = 0,
    this.onTap,
  });
}

/// Layout professionnel : sidebar fixe a gauche (desktop) ou drawer (mobile),
/// AppBar avec bouton retour + actions.
class ProLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final String currentRoute;
  final List<ProMenuItem> items;
  final Widget body;
  final VoidCallback? onLogout;
  final List<Widget>? actions;
  final bool showBackButton;

  const ProLayout({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.currentRoute,
    required this.items,
    required this.body,
    this.onLogout,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : Drawer(child: _SidebarContent(items: items, currentRoute: currentRoute, title: title)),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                tooltip: 'Retour',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : (!isDesktop
                ? Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                      tooltip: 'Menu',
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  )
                : null),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          if (actions != null) ...actions!,
          if (onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.danger),
              tooltip: 'Deconnexion',
              onPressed: onLogout,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                SizedBox(
                  width: 260,
                  child: _SidebarContent(items: items, currentRoute: currentRoute, title: title),
                ),
                const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                Expanded(child: body),
              ],
            )
          : body,
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final List<ProMenuItem> items;
  final String currentRoute;
  final String title;

  const _SidebarContent({
    required this.items,
    required this.currentRoute,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER avec logo + titre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mauve, AppColors.kaki],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'ChefUnitPlus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.map((it) => _SidebarTile(item: it, currentRoute: currentRoute)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final ProMenuItem item;
  final String currentRoute;
  const _SidebarTile({required this.item, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isSelected = item.route == currentRoute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? item.color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            if (item.onTap != null) {
              item.onTap!();
            } else if (item.route != currentRoute) {
              Navigator.of(context).pushReplacementNamed(item.route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Icone avec fond colore
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: isSelected ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? item.color : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (item.badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}