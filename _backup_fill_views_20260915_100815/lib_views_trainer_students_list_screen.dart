// =============================================================
// ChefUnitPlus - StudentsListScreen
// Liste des tudiants inscrits aux modules du formateur
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/enrollment.dart';
import '../../models/user.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentController>().loadPending();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Enrollment> _filter(List<Enrollment> list) {
    if (_query.trim().isEmpty) return list;
    final q = _query.toLowerCase();
    return list
        .where((e) =>
            e.learnerName.toLowerCase().contains(q) ||
            e.formationTitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<EnrollmentController>();

    final approved = ctrl.pending.where((e) => e.isApproved).toList();
    final pending = ctrl.pending.where((e) => e.isPending).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.studentsList),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Actifs (${approved.length})'),
            Tab(text: 'En attente (${pending.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un tudiant...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildList(
                        _filter(approved),
                        'Aucun tudiant actif',
                        Icons.people_outline,
                      ),
                      _buildList(
                        _filter(pending),
                        'Aucune inscription en attente',
                        Icons.hourglass_empty,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    List<Enrollment> list,
    String emptyMsg,
    IconData emptyIcon,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                emptyMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EnrollmentController>().loadPending(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _StudentTile(enrollment: list[i]),
      ),
    );
  }
}

// =============================================================
// Y' TUILE ?TUDIANT
// =============================================================
class _StudentTile extends StatelessWidget {
  final Enrollment enrollment;
  const _StudentTile({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final initials = Formatters.initials(enrollment.learnerName);
    final isApproved = enrollment.isApproved;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isApproved
                  ? AppColors.successSoft
                  : AppColors.warningSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isApproved
                      ? AppColors.successDark
                      : AppColors.warning,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enrollment.learnerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  enrollment.formationTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isApproved
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isApproved
                      ? Icons.check_circle_outline
                      : Icons.hourglass_empty,
                  size: 14,
                  color:
                      isApproved ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  enrollment.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isApproved ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Y"O WIDGET UTILITAIRE (non utilis directement mais prt)
// =============================================================
// ignore: unused_element
class _UserHeader extends StatelessWidget {
  final User user;
  const _UserHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.mauveSoft,
          child: Text(user.initials),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(user.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
void _refreshUser(AuthController auth) {
  auth.refreshUser();
}