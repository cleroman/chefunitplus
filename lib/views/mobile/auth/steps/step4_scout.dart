// =============================================================
// ChefUnitPlus - Etape 4 : Scout (avec selection du groupe)
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/controllers/scout_group_controller.dart';
import 'package:chefunitplus/core/utils/validators.dart';
import 'package:chefunitplus/models/scout_group.dart';
import 'package:chefunitplus/models/user_details.dart';
import 'package:chefunitplus/widgets/common/custom_text_field.dart';
import '../register_wizard_screen.dart';

class Step4Scout extends StatelessWidget {
  final RegisterWizardScreenState state;

  const Step4Scout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final groupCtrl = context.watch<ScoutGroupController>();
    final groups = groupCtrl.publicGroups;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle(
          icon: Icons.groups_outlined,
          title: 'Informations scout',
          subtitle: 'Selectionnez votre groupe et renseignez vos infos',
        ),
        const SizedBox(height: 24),

        // ===== SELECTION DU GROUPE (dropdown) =====
        const Text(
          'Groupe scout *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        if (groupCtrl.isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Chargement des groupes...'),
              ],
            ),
          )
        else if (groups.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aucun groupe scout disponible. Contactez un administrateur.',
                    style: TextStyle(fontSize: 12, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.groupeScoutId,
                isExpanded: true,
                hint: const Text('Choisir un groupe'),
                icon: const Icon(Icons.arrow_drop_down),
                items: groups.map((ScoutGroup g) {
                  return DropdownMenuItem<String>(
                    value: g.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          g.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((g.region ?? '').isNotEmpty)
                          Text(
                            g.region!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  state.groupeScoutId = v;
                  if (v != null) {
                    final g = groups.firstWhere((g) => g.id == v);
                    state.groupeScoutCtrl.text = g.name;
                    state.districtCtrl.text = g.district ?? '';
                    state.regionCtrl.text = g.region ?? '';
                  }
                  state.refresh();
                },
              ),
            ),
          ),

        const SizedBox(height: 24),

        // ===== NUMERO AFFILIATION =====
        CustomTextField(
          label: 'Numero d\'affiliation *',
          hint: 'Ex : KIN-2024-001',
          controller: state.numeroAffiliationCtrl,
          icon: Icons.badge_outlined,
          validator: (v) => Validators.required(v, fieldName: 'Numero affiliation'),
        ),
        const SizedBox(height: 16),

        // ===== DISTRICT =====
        CustomTextField(
          label: 'District',
          hint: 'Auto-rempli avec le groupe',
          controller: state.districtCtrl,
          icon: Icons.map_outlined,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        // ===== ASSOCIATION =====
        CustomTextField(
          label: 'Association',
          hint: 'Ex : Association des Scouts du Congo',
          controller: state.associationCtrl,
          icon: Icons.business_outlined,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 24),

        // ===== BRANCHE =====
        const Text(
          'Branche *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ScoutBranch>(
              value: state.branche,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: ScoutBranch.values
                  .where((b) => b != ScoutBranch.autre)
                  .map((b) {
                return DropdownMenuItem<ScoutBranch>(
                  value: b,
                  child: Row(
                    children: [
                      const Icon(Icons.flag, size: 18, color: AppColors.mauve),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              b.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (ScoutBranch? newValue) {
                if (newValue != null) {
                  state.branche = newValue;
                  state.refresh();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ===== DATE ENTREE SCOUT =====
        InkWell(
          onTap: () => _pickDateEntree(context),
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date d\'entree au scoutisme',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
            ),
            child: Text(
              state.dateEntreeScout != null
                  ? _formatDate(state.dateEntreeScout!)
                  : 'Choisir une date',
              style: TextStyle(
                color: state.dateEntreeScout != null
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ===== FONCTION =====
        CustomTextField(
          label: 'Fonction (optionnel)',
          hint: 'Ex : Chef de patrouille',
          controller: state.fonctionScoutCtrl,
          icon: Icons.workspace_premium_outlined,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Future<void> _pickDateEntree(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dateEntreeScout ?? DateTime(2010),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Date d\'entree au scoutisme',
    );
    if (picked != null) {
      state.dateEntreeScout = picked;
      state.refresh();
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.mauve.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.mauve, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}