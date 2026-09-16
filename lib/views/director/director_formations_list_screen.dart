import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/formation_controller.dart';
import '../../models/formation.dart';
import 'formation_editor_screen.dart';

class DirectorFormationsListScreen extends StatefulWidget {
  const DirectorFormationsListScreen({super.key});

  @override
  State<DirectorFormationsListScreen> createState() =>
      _DirectorFormationsListScreenState();
}

class _DirectorFormationsListScreenState
    extends State<DirectorFormationsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormationController>().load(all: true, refresh: true);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FormationController>();
    List<Formation> all = ctrl.formations;

    // Recherche
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      all = all
          .where((f) =>
              f.title.toLowerCase().contains(q) ||
              f.description.toLowerCase().contains(q))
          .toList();
    }

    final drafts = all.where((f) => !f.isPublished).toList();
    final published = all.where((f) => f.isPublished).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes formations'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Toutes (${all.length})'),
            Tab(text: 'Brouillons (${drafts.length})'),
            Tab(text: 'Publiees (${published.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: ctrl.isLoading && all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildList(all),
                      _buildList(drafts),
                      _buildList(published),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECHERCHE
  // ============================================================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Rechercher une formation...',
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
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTE
  // ============================================================
  Widget _buildList(List<Formation> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.mauve.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_outlined,
                    size: 60, color: AppColors.mauve),
              ),
              const SizedBox(height: 20),
              const Text(
                'Aucune formation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Creez votre premiere formation',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<FormationController>().load(all: true, refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i]),
      ),
    );
  }

  Widget _buildCard(Formation f) {
    final modulesCount = f.moduleCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openEditor(f),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header : titre + badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.mauve.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school, color: AppColors.mauve),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: f.isPublished
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  f.isPublished ? 'Publiee' : 'Brouillon',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: f.isPublished
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                f.type.label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats ligne
                Row(
                  children: [
                    _infoBadge(Icons.list, '$modulesCount module(s)'),
                    const SizedBox(width: 12),
                    _infoBadge(Icons.schedule, '${f.totalHours}h'),
                    const SizedBox(width: 12),
                    _infoBadge(Icons.attach_money, f.priceLabel),
                  ],
                ),
                const SizedBox(height: 14),
                // Actions
                Row(
                  children: [
                    if (!f.isPublished) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: modulesCount > 0
                              ? () => _publish(f)
                              : null,
                          icon: const Icon(Icons.public, size: 16),
                          label: const Text('Publier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.success.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _unpublish(f),
                          icon: const Icon(Icons.visibility_off, size: 16),
                          label: const Text('Depublier'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(color: AppColors.warning),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => _openEditor(f),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.mauve,
                        side: const BorderSide(color: AppColors.mauve),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!f.isPublished && modulesCount == 0) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez au moins 1 module valide pour publier',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.danger,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================
  Future<void> _publish(Formation f) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publier la formation'),
        content: Text(
          'Publier "${f.title}" ?\n\n'
          'Elle sera visible dans le catalogue des apprenants.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Publier'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (!mounted) return;
    final ctrl = context.read<FormationController>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await ctrl.publish(f.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Formation publiee' : 'Echec de publication'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _unpublish(Formation f) async {
    if (!mounted) return;
    final ctrl = context.read<FormationController>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await ctrl.unpublish(f.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Formation depubliee' : 'Echec'),
        backgroundColor: ok ? AppColors.warning : AppColors.danger,
      ),
    );
  }

  Future<void> _openEditor([Formation? formation]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormationEditorScreen(
          formationId: formation?.id,
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<FormationController>().load(all: true, refresh: true);
    }
  }
}