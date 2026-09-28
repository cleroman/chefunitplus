// ChefUnitPlus - Etape 3 : Adresse
import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import '../register_wizard_screen.dart';

class Step3Address extends StatelessWidget {
  final RegisterWizardScreenState state;
  const Step3Address({super.key, required this.state});

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
                Icon(Icons.location_on_outlined,
                    color: AppColors.mauve, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Votre adresse complete',
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
            controller: state.provinceCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Province *',
              prefixIcon: Icon(Icons.map_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.villeCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Ville *',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.communeCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Commune *',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.quartierCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Quartier *',
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.avenueCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Avenue *',
              prefixIcon: Icon(Icons.signpost_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.numeroCtrl,
            decoration: const InputDecoration(
              labelText: 'Numero *',
              prefixIcon: Icon(Icons.tag),
            ),
          ),
        ],
      ),
    );
  }
}