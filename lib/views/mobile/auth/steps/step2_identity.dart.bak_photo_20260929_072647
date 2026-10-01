// ChefUnitPlus - Etape 2 : Identite
import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/core/utils/formatters.dart';
import '../register_wizard_screen.dart';

class Step2Identity extends StatelessWidget {
  final RegisterWizardScreenState state;
  const Step2Identity({super.key, required this.state});

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dateNaissance ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      state.dateNaissance = picked;
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
              color: AppColors.mauveSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_outline,
                    color: AppColors.mauve, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informations personnelles',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mauveDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: state.postNomCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Post-nom *',
              hintText: 'Ex : DUPONT',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.prenomCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Prenom *',
              hintText: 'Ex : Jean',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.prenom2Ctrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: '2eme prenom (optionnel)',
              prefixIcon: Icon(Icons.person_add_outlined),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: state.sexe,
            decoration: const InputDecoration(
              labelText: 'Sexe *',
              prefixIcon: Icon(Icons.wc),
            ),
            items: const [
              DropdownMenuItem(value: 'homme', child: Text('Masculin')),
              DropdownMenuItem(value: 'femme', child: Text('Feminin')),
            ],
            onChanged: (v) {
              if (v != null) {
                state.sexe = v;
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
                labelText: 'Date de naissance *',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                state.dateNaissance != null
                    ? Formatters.dateShort(state.dateNaissance!)
                    : 'Selectionner une date',
                style: TextStyle(
                  color: state.dateNaissance != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.lieuNaissanceCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Lieu de naissance *',
              hintText: 'Ex : Kinshasa',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
