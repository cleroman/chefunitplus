// ChefUnitPlus - Etape 4 : Scout
import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/core/utils/formatters.dart';
import 'package:chefunitplus/models/user_details.dart';
import '../register_wizard_screen.dart';

class Step4Scout extends StatelessWidget {
  final RegisterWizardScreenState state;
  const Step4Scout({super.key, required this.state});

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dateEntreeScout ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      state.dateEntreeScout = picked;
      state.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.kakiSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.flag_outlined,
                    color: AppColors.kakiDark, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informations scouts',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kakiDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: state.groupeScoutCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Groupe scout *',
              prefixIcon: Icon(Icons.groups_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.numeroAffiliationCtrl,
            decoration: const InputDecoration(
              labelText: 'Numero d\'affiliation',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.districtCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'District',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.associationCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Association',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ScoutBranch>(
            initialValue: state.branche,
            decoration: const InputDecoration(
              labelText: 'Branche *',
              prefixIcon: Icon(Icons.account_tree_outlined),
            ),
            items: ScoutBranch.values
                .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(b.label),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                state.branche = v;
                state.refresh();
              }
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date d\'entree scout *',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                state.dateEntreeScout != null
                    ? Formatters.dateShort(state.dateEntreeScout!)
                    : 'Selectionner',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.fonctionScoutCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Fonction scout (optionnel)',
              prefixIcon: Icon(Icons.star_outline),
            ),
          ),
        ],
      ),
    );
  }
}
