// =============================================================
// ChefUnitPlus - Etape 6 : Engagement
// =============================================================

import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import '../register_wizard_screen.dart';

class Step6Engagement extends StatelessWidget {
  final RegisterWizardScreenState state;

  const Step6Engagement({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Engagement scout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.kakiSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Je m\'engage a :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '- Respecter les valeurs du scoutisme\n'
                  '- Participer aux activites\n'
                  '- Contribuer au developpement\n'
                  '- Respecter les autres membres',
                  style: TextStyle(fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: state.engagementAccepte,
            onChanged: (v) {
              state.engagementAccepte = v ?? false;
              state.refresh();
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'J\'accepte l\'engagement scout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Vous devez accepter pour creer votre compte',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}