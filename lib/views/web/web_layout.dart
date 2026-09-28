// =============================================================
// ChefUnitPlus - WebLayout
// Layout Web : Sidebar a gauche + contenu a droite.
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';

class WebMenuItem {
  final IconData icon;
  final String label;
  final String route;

  const WebMenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class WebLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int selectedIndex;
  final List<WebMenuItem> menuItems;

  const WebLayout({
    super.key,
    required this.child,
    required this.title,
    required this.selectedIndex,
    required this.menuItems,
  });

  @override
  State<WebLayout> createState() => _WebLayoutState();
}

class _WebLayoutState extends State<WebLayout> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ============ SIDEBAR ============
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _collapsed ? 70 : 250,
            color: AppColors.mauve,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (!_collapsed)
                        const Expanded(
                          child: Text(
                            'ChefUnitPlus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _collapsed ? Icons.menu : Icons.menu_open,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _collapsed = !_collapsed);
                        },
                      ),
                    ],
                  ),
                ),

                // Menu items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: widget.menuItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.menuItems[index];
                      final isSelected = index == widget.selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              if (item.route.isNotEmpty &&
                                  item.route != ModalRoute.of(context)?.settings.name) {
                                Navigator.pushReplacementNamed(
                                    context, item.route);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(item.icon, color: Colors.white, size: 22),
                                  if (!_collapsed) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Deconnexion
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        context.read<AuthController>().logout();
                        Navigator.pushReplacementNamed(context, '/auth/login');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.logout,
                                color: Colors.white, size: 22),
                            if (!_collapsed) ...[
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Deconnexion',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============ CONTENU ============
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        tooltip: 'Notifications',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.mail_outline),
                        tooltip: 'Messages',
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor:
                            AppColors.mauve.withValues(alpha: 0.15),
                        child: const Icon(Icons.person,
                            color: AppColors.mauve),
                      ),
                    ],
                  ),
                ),

                // Contenu
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}