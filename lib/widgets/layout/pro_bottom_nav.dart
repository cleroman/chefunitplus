// =============================================================
// ChefUnitPlus - ProBottomNav
// Bottom navigation professionnelle (mobile)
// 5 items adaptes au role de l'utilisateur connecte
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/role_constants.dart';
import '../../controllers/auth_controller.dart';

class ProBottomNavItem {
  final IconData icon;
  final String label;
  final String route;

  const ProBottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class ProBottomNav extends StatelessWidget {
  final int currentIndex;

  const ProBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  List<ProBottomNavItem> _itemsForRole(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const [
          ProBottomNavItem(icon: Icons.dashboard_outlined, label: 'Accueil', route: '/admin'),
          ProBottomNavItem(icon: Icons.people_outline, label: 'Users', route: '/admin/users'),
          ProBottomNavItem(icon: Icons.payments_outlined, label: 'Paiements', route: '/admin/payments'),
          ProBottomNavItem(icon: Icons.video_library_outlined, label: 'Videos', route: '/scout-videos'),
          ProBottomNavItem(icon: Icons.person_outline, label: 'Profil', route: '/profile'),
        ];
      case UserRole.directeur:
        return const [
          ProBottomNavItem(icon: Icons.dashboard_outlined, label: 'Accueil', route: '/director'),
          ProBottomNavItem(icon: Icons.school_outlined, label: 'Formations', route: '/director/formations'),
          ProBottomNavItem(icon: Icons.assignment_turned_in_outlined, label: 'Validations', route: '/director/enrollments'),
          ProBottomNavItem(icon: Icons.video_library_outlined, label: 'Videos', route: '/scout-videos'),
          ProBottomNavItem(icon: Icons.person_outline, label: 'Profil', route: '/profile'),
        ];
      case UserRole.formateur:
        return const [
          ProBottomNavItem(icon: Icons.dashboard_outlined, label: 'Accueil', route: '/trainer'),
          ProBottomNavItem(icon: Icons.school_outlined, label: 'Modules', route: '/trainer/modules'),
          ProBottomNavItem(icon: Icons.qr_code_scanner, label: 'Scan', route: '/trainer/attendance'),
          ProBottomNavItem(icon: Icons.video_library_outlined, label: 'Videos', route: '/scout-videos'),
          ProBottomNavItem(icon: Icons.person_outline, label: 'Profil', route: '/profile'),
        ];
      case UserRole.apprenant:
      default:
        return const [
          ProBottomNavItem(icon: Icons.dashboard_outlined, label: 'Accueil', route: '/learner'),
          ProBottomNavItem(icon: Icons.school_outlined, label: 'Formations', route: '/learner/catalog'),
          ProBottomNavItem(icon: Icons.payment, label: 'Paiement', route: '/learner/payment'),
          ProBottomNavItem(icon: Icons.video_library_outlined, label: 'Videos', route: '/scout-videos'),
          ProBottomNavItem(icon: Icons.person_outline, label: 'Profil', route: '/learner/profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthController>().currentUser?.role;
    final items = _itemsForRole(role);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, items.length - 1),
          onTap: (i) {
            if (i == currentIndex) return;
            final route = items[i].route;
            Navigator.pushNamed(context, route);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.mauve,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: items.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.icon, color: AppColors.mauve),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
