import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/formation_controller.dart';
import '../../controllers/password_request_controller.dart';
import '../../controllers/complaint_controller.dart';
import '../../widgets/layout/pro_layout.dart';
import 'users_management_screen.dart';
import 'promote_screen.dart';
import 'global_stats_screen.dart';
import 'payments_log_screen.dart';
import 'complaints_screen.dart';
import 'password_requests_screen.dart';
import 'scout_groups_screen.dart';
import 'system_settings_screen.dart';
import '../shared/conversations_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _currentRoute = AppRoutes.adminHome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    final userCtrl = context.read<UserController>();
    final formCtrl = context.read<FormationController>();
    final pwdCtrl = context.read<PasswordRequestController>();
    final compCtrl = context.read<ComplaintController>();
    await Future.wait([
      userCtrl.loadAll(refresh: true),
      formCtrl.load(all: true, refresh: true),
      pwdCtrl.load(),
      compCtrl.loadAll(),
    ]);
  }

  void _navigate(Widget screen, String route) {
    setState(() => _currentRoute = route);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) {
      if (mounted) {
        setState(() => _currentRoute = AppRoutes.adminHome);
        _loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final userCtrl = context.watch<UserController>();
    final formCtrl = context.watch<FormationController>();
    final pwdCtrl = context.watch<PasswordRequestController>();
    final compCtrl = context.watch<ComplaintController>();

    final users = userCtrl.users;
    final formations = formCtrl.formations;
    final pendingPwd = pwdCtrl.requests.where((r) => r.isPending).length;
    final openComplaints = compCtrl.complaints
        .where((c) => c.status.name.toLowerCase() == 'open')
        .length;

    final items = [
      const ProMenuItem(
        icon: Icons.dashboard_outlined,
        label: 'Tableau de bord',
        route: AppRoutes.adminHome,
        color: AppColors.mauve,
      ),
      ProMenuItem(
        icon: Icons.people_outline,
        label: 'Utilisateurs',
        route: AppRoutes.adminUsers,
        color: Colors.blue,
        badge: users.length,
        onTap: () => _navigate(const UsersManagementScreen(), AppRoutes.adminUsers),
      ),
      ProMenuItem(
        icon: Icons.upgrade_outlined,
        label: 'Promotions',
        route: AppRoutes.adminPromote,
        color: Colors.orange,
        onTap: () => _navigate(const PromoteScreen(), AppRoutes.adminPromote),
      ),
      ProMenuItem(
        icon: Icons.bar_chart_outlined,
        label: 'Statistiques',
        route: AppRoutes.adminStats,
        color: Colors.teal,
        onTap: () => _navigate(const GlobalStatsScreen(), AppRoutes.adminStats),
      ),
      ProMenuItem(
        icon: Icons.payments_outlined,
        label: 'Paiements',
        route: AppRoutes.adminPayments,
        color: Colors.green,
        onTap: () => _navigate(const PaymentsLogScreen(), AppRoutes.adminPayments),
      ),
      ProMenuItem(
        icon: Icons.report_problem_outlined,
        label: 'Reclamations',
        route: AppRoutes.adminComplaints,
        color: Colors.red,
        badge: openComplaints,
        onTap: () => _navigate(const ComplaintsScreen(), AppRoutes.adminComplaints),
      ),
      ProMenuItem(
        icon: Icons.lock_reset,
        label: 'Mots de passe',
        route: AppRoutes.adminPasswordRequests,
        color: Colors.purple,
        badge: pendingPwd,
        onTap: () => _navigate(const PasswordRequestsScreen(), AppRoutes.adminPasswordRequests),
      ),
      ProMenuItem(
        icon: Icons.groups_outlined,
        label: 'Groupes scouts',
        route: AppRoutes.adminScoutGroups,
        color: Colors.brown,
        onTap: () => _navigate(const ScoutGroupsScreen(), AppRoutes.adminScoutGroups),
      ),
      ProMenuItem(
        icon: Icons.settings_outlined,
        label: 'Systeme',
        route: AppRoutes.adminSettings,
        color: Colors.grey,
        onTap: () => _navigate(const SystemSettingsScreen(), AppRoutes.adminSettings),
      ),
      ProMenuItem(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        route: AppRoutes.adminMessages,
        color: Colors.cyan,
        onTap: () => _navigate(const ConversationsScreen(), AppRoutes.adminMessages),
      ),
    ];

    return ProLayout(
      title: 'Administration',
      subtitle: user?.fullName ?? 'Administrateur',
      currentRoute: _currentRoute,
      items: items,
      onLogout: _confirmLogout,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildStatsRow(users.length, formations.length, userCtrl.adminCount, userCtrl.trainerCount),
            const SizedBox(height: 24),
            if (pendingPwd > 0 || openComplaints > 0)
              _buildPendingBanners(pendingPwd, openComplaints),
            if (pendingPwd > 0 || openComplaints > 0) const SizedBox(height: 24),
            _sectionTitle('Gestion rapide'),
            const SizedBox(height: 12),
            _buildManagementGrid(pendingPwd, openComplaints),
            const SizedBox(height: 24),
            _sectionTitle('Plateforme'),
            const SizedBox(height: 12),
            _buildPlatformGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.mauve,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(t,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
        ],
      );

  Widget _buildStatsRow(int u, int f, int a, int t) {
    return Row(
      children: [
        _statCard('$u', 'Utilisateurs', Icons.people, Colors.blue),
        const SizedBox(width: 12),
        _statCard('$f', 'Formations', Icons.school, AppColors.mauve),
        const SizedBox(width: 12),
        _statCard('$t', 'Formateurs', Icons.cast_for_education, Colors.green),
        const SizedBox(width: 12),
        _statCard('$a', 'Admins', Icons.admin_panel_settings, Colors.purple),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBanners(int pwd, int comp) {
    return Column(
      children: [
        if (pwd > 0)
          _banner(
            icon: Icons.lock_reset,
            color: Colors.purple,
            text: '$pwd demande(s) de mot de passe en attente',
            onTap: () => _navigate(const PasswordRequestsScreen(), AppRoutes.adminPasswordRequests),
          ),
        if (pwd > 0 && comp > 0) const SizedBox(height: 10),
        if (comp > 0)
          _banner(
            icon: Icons.report_problem,
            color: Colors.red,
            text: '$comp reclamation(s) ouverte(s)',
            onTap: () => _navigate(const ComplaintsScreen(), AppRoutes.adminComplaints),
          ),
      ],
    );
  }

  Widget _banner({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ),
            Icon(Icons.arrow_forward_ios, size: 13, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementGrid(int pwd, int comp) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _actionCard(
          icon: Icons.people_outline,
          title: 'Utilisateurs',
          subtitle: 'Gerer les comptes',
          color: Colors.blue,
          onTap: () => _navigate(const UsersManagementScreen(), AppRoutes.adminUsers),
        ),
        _actionCard(
          icon: Icons.upgrade_outlined,
          title: 'Promotions',
          subtitle: 'Changer les roles',
          color: Colors.orange,
          onTap: () => _navigate(const PromoteScreen(), AppRoutes.adminPromote),
        ),
        _actionCard(
          icon: Icons.lock_reset,
          title: 'Mots de passe',
          subtitle: 'Demandes en attente',
          color: Colors.purple,
          badge: pwd,
          onTap: () => _navigate(const PasswordRequestsScreen(), AppRoutes.adminPasswordRequests),
        ),
        _actionCard(
          icon: Icons.report_problem_outlined,
          title: 'Reclamations',
          subtitle: 'Support utilisateurs',
          color: Colors.red,
          badge: comp,
          onTap: () => _navigate(const ComplaintsScreen(), AppRoutes.adminComplaints),
        ),
      ],
    );
  }

  Widget _buildPlatformGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _actionCard(
          icon: Icons.bar_chart_outlined,
          title: 'Statistiques',
          subtitle: 'Vue globale',
          color: Colors.teal,
          onTap: () => _navigate(const GlobalStatsScreen(), AppRoutes.adminStats),
        ),
        _actionCard(
          icon: Icons.payments_outlined,
          title: 'Paiements',
          subtitle: 'Journal complet',
          color: Colors.green,
          onTap: () => _navigate(const PaymentsLogScreen(), AppRoutes.adminPayments),
        ),
        _actionCard(
          icon: Icons.groups_outlined,
          title: 'Groupes scouts',
          subtitle: 'Gestion groupes',
          color: Colors.brown,
          onTap: () => _navigate(const ScoutGroupsScreen(), AppRoutes.adminScoutGroups),
        ),
        _actionCard(
          icon: Icons.settings_outlined,
          title: 'Systeme',
          subtitle: 'Configuration',
          color: Colors.grey,
          onTap: () => _navigate(const SystemSettingsScreen(), AppRoutes.adminSettings),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              if (badge > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$badge',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );
  }
}