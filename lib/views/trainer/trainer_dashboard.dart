import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/module_controller.dart';
import '../../widgets/layout/pro_layout.dart';
import 'trainer_create_module_screen.dart';
import 'trainer_my_modules_screen.dart';
import 'students_list_screen.dart';
import '../shared/conversations_screen.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});
  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  String _currentRoute = AppRoutes.trainerHome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    await context.read<ModuleController>().loadPending(refresh: true);
  }

  void _navigate(Widget screen, String route) {
    setState(() => _currentRoute = route);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (mounted) {
        setState(() => _currentRoute = AppRoutes.trainerHome);
        _loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final ctrl = context.watch<ModuleController>();
    final myModules = ctrl.myModules;

    // Compter par statut (filtre defensif sur .name)
    final approved = myModules.where((m) => m.status.name == 'approved').length;
    final pending  = myModules.where((m) => m.status.name == 'pending').length;
    final rejected = myModules.where((m) => m.status.name == 'rejected').length;
    final totalHours = myModules
        .where((m) => m.status.name == 'approved')
        .fold<int>(0, (s, m) => s + (m.hours));

    final items = [
      const ProMenuItem(
        icon: Icons.dashboard_outlined,
        label: 'Tableau de bord',
        route: AppRoutes.trainerHome,
        color: AppColors.mauve,
      ),
      ProMenuItem(
        icon: Icons.add_circle_outline,
        label: 'Proposer un module',
        route: AppRoutes.trainerCreateModule,
        color: Colors.blue,
        onTap: () => _navigate(const TrainerCreateModuleScreen(), AppRoutes.trainerCreateModule),
      ),
      ProMenuItem(
        icon: Icons.library_books_outlined,
        label: 'Mes modules',
        route: AppRoutes.trainerMyModules,
        color: Colors.green,
        badge: approved,
        onTap: () => _navigate(const TrainerMyModulesScreen(), AppRoutes.trainerMyModules),
      ),
      ProMenuItem(
        icon: Icons.hourglass_empty,
        label: 'En attente',
        route: AppRoutes.trainerMyModules,
        color: Colors.orange,
        badge: pending,
        onTap: () => _navigate(const TrainerMyModulesScreen(), AppRoutes.trainerMyModules),
      ),
      ProMenuItem(
        icon: Icons.people_outline,
        label: 'Mes etudiants',
        route: AppRoutes.trainerStudents,
        color: Colors.teal,
        onTap: () => _navigate(const StudentsListScreen(), AppRoutes.trainerStudents),
      ),
      ProMenuItem(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        route: AppRoutes.trainerMessages,
        color: Colors.cyan,
        onTap: () => _navigate(const ConversationsScreen(), AppRoutes.trainerMessages),
      ),
    ];

    return ProLayout(
      title: 'Espace Formateur',
      subtitle: user?.fullName ?? 'Formateur',
      currentRoute: _currentRoute,
      items: items,
      onLogout: _logout,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _statsRow(approved, pending, rejected, totalHours),
            const SizedBox(height: 24),
            if (pending > 0) ...[
              _banner(Icons.hourglass_empty, Colors.orange,
                  '$pending module(s) en attente de validation',
                  () => _navigate(const TrainerMyModulesScreen(), AppRoutes.trainerMyModules)),
              const SizedBox(height: 12),
            ],
            if (rejected > 0) ...[
              _banner(Icons.cancel, Colors.red,
                  '$rejected module(s) refuse(s) - voir le motif',
                  () => _navigate(const TrainerMyModulesScreen(), AppRoutes.trainerMyModules)),
              const SizedBox(height: 12),
            ],
            _sectionTitle('Actions rapides'),
            const SizedBox(height: 12),
            _actionsGrid(pending, approved),
            const SizedBox(height: 24),
            _sectionTitle('Mes modules recents'),
            const SizedBox(height: 12),
            if (myModules.isEmpty)
              _emptyCard()
            else
              ...myModules.take(3).map(_moduleCard),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
              color: AppColors.mauve,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(t, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      );

  Widget _statsRow(int app, int pend, int rej, int hours) {
    return Row(children: [
      _stat('$app', 'Valides', Icons.check_circle, Colors.green),
      const SizedBox(width: 12),
      _stat('$pend', 'En attente', Icons.hourglass_empty, Colors.orange),
      const SizedBox(width: 12),
      _stat('$rej', 'Refuses', Icons.cancel, Colors.red),
      const SizedBox(width: 12),
      _stat('${hours}h', 'Total', Icons.schedule, AppColors.mauve),
    ]);
  }

  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _banner(IconData icon, Color color, String text, VoidCallback onTap) {
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
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color))),
          Icon(Icons.arrow_forward_ios, size: 13, color: color),
        ]),
      ),
    );
  }

  Widget _actionsGrid(int pending, int approved) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _card(Icons.add_circle_outline, 'Proposer', 'Nouveau module', Colors.blue, 0,
            () => _navigate(const TrainerCreateModuleScreen(), AppRoutes.trainerCreateModule)),
        _card(Icons.library_books_outlined, 'Mes modules', 'Voir tous', Colors.green, approved,
            () => _navigate(const TrainerMyModulesScreen(), AppRoutes.trainerMyModules)),
        _card(Icons.hourglass_empty, 'En attente', 'Modules proposes', Colors.orange, pending,
            () => _navigate(const TrainerMyModulesScreen(), AppRoutes.trainerMyModules)),
        _card(Icons.people_outline, 'Etudiants', 'Voir les apprenants', Colors.teal, 0,
            () => _navigate(const StudentsListScreen(), AppRoutes.trainerStudents)),
      ],
    );
  }

  Widget _card(IconData icon, String title, String subtitle, Color color, int badge, VoidCallback onTap) {
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
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))],
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
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(title, style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
              if (badge > 0)
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10)),
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

  Widget _moduleCard(dynamic m) {
    final statusName = m.status.name;
    Color color;
    String label;
    if (statusName == 'approved') {
      color = Colors.green;
      label = 'Valide';
    } else if (statusName == 'rejected') {
      color = Colors.red;
      label = 'Refuse';
    } else {
      color = Colors.orange;
      label = 'En attente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.library_books, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.title ?? 'Module',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
        ),
        Text('${m.hours}h',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mauve)),
      ]),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(Icons.library_books_outlined,
            size: 48, color: AppColors.mauve.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        const Text('Aucun module',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Proposez votre premier module',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
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