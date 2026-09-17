// =============================================================
// ChefUnitPlus - Etape 4 : Scout
// =============================================================

import 'package:flutter/material.dart';

import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/models/user_details.dart';
import '../register_wizard_screen.dart';

class Step4Scout extends StatelessWidget {
  final RegisterWizardScreenState state;

  const Step4Scout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionTitle(
          icon: Icons.groups_outlined,
          title: 'Informations scout',
          subtitle: 'Votre groupe, branche et fonction',
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: state.groupeScoutCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Groupe scout',
            hintText: 'Ex : Groupe Kimbondo',
            prefixIcon: Icon(Icons.flag_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.numeroAffiliationCtrl,
          decoration: const InputDecoration(
            labelText: 'Numero d\'affiliation',
            hintText: 'Ex : KIN-2024-001',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.districtCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'District',
            hintText: 'Ex : District de Kinshasa',
            prefixIcon: Icon(Icons.map_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.associationCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Association',
            hintText: 'Ex : Association des Scouts du Congo',
            prefixIcon: Icon(Icons.business_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Branche',
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
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ScoutBranch>(
              value: state.branche,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: ScoutBranch.values.map((b) {
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
        TextFormField(
          controller: state.fonctionScoutCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Fonction (optionnel)',
            hintText: 'Ex : Chef de patrouille',
            prefixIcon: Icon(Icons.workspace_premium_outlined),
            border: OutlineInputBorder(),
          ),
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