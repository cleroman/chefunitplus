import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/formation_controller.dart';
import '../../models/formation.dart';
import 'formation_detail_screen.dart';

class FormationCatalogScreen extends StatefulWidget {
  const FormationCatalogScreen({super.key});

  @override
  State<FormationCatalogScreen> createState() => _FormationCatalogScreenState();
}

class _FormationCatalogScreenState extends State<FormationCatalogScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormationController>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FormationController>();

    List<Formation> formations = ctrl.formations;
    if (_query.isNotEmpty) {
      formations = formations
          .where((f) =>
              f.title.toLowerCase().contains(_query.toLowerCase()) ||
              f.description.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    if (_sortBy == 'price_asc') {
      formations.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      formations.sort((a, b) => b.price.compareTo(a.price));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          if (ctrl.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (ctrl.hasError)
            SliverFillRemaining(child: _errorView(ctrl))
          else if (formations.isEmpty)
            SliverFillRemaining(child: _emptyView())
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _formationCard(formations[i]),
                  childCount: formations.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: AppColors.mauve,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Catalogue',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.mauve, AppColors.kaki],
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Decouvrez nos formations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          children: [
            TextField(
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.tune, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                const Text(
                  'Trier par :',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                _sortChip('Recents', 'recent'),
                const SizedBox(width: 8),
                _sortChip('Prix +', 'price_asc'),
                const SizedBox(width: 8),
                _sortChip('Prix -', 'price_desc'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final selected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.mauve : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.mauve : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================
  Widget _errorView(FormationController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oups, une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ctrl.errorMessage ?? 'Impossible de charger les formations',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ctrl.load(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mauve,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY VIEW
  // ============================================================
  Widget _emptyView() {
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
              child: const Icon(
                Icons.school_outlined,
                size: 60,
                color: AppColors.mauve,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _query.isEmpty
                  ? 'Aucune formation disponible'
                  : 'Aucun resultat pour "$_query"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _query.isEmpty
                  ? 'Revenez plus tard pour voir les nouvelles formations.'
                  : 'Essayez avec un autre mot-cle.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMATION CARD
  // ============================================================
  Widget _formationCard(Formation f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetail(f),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverImage(f),
              _buildCardContent(f),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(Formation f) {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mauve, AppColors.kaki],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: f.coverImage != null && f.coverImage!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                f.coverImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.school,
                size: 60,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildCardContent(Formation f) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            f.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            f.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mauve.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 14,
                        color: AppColors.mauve,
                      ),
                      Text(
                        f.priceLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mauve,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _openDetail(f),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Voir',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDetail(Formation f) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormationDetailScreen(formationId: f.id),
      ),
    );
  }
}