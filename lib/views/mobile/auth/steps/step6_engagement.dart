// =============================================================
// ChefUnitPlus - Etape 6 : Engagement
// =============================================================

import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/core/utils/validators.dart';
import 'package:chefunitplus/widgets/common/custom_text_field.dart';
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
          // ============================================================
          // EMAIL DE CONFIRMATION
          // ============================================================
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mauveSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mauve.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mark_email_read_outlined,
                        color: AppColors.mauve, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adresse email de confirmation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mauve,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Le message de felicitations et les notifications importantes (validation de paiement, formations) seront envoyes a cette adresse.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: '',
                  hint: 'exemple@email.com',
                  controller: state.confirmationEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email_outlined,
                  validator: Validators.email,
                ),
              ],
            ),
          ),
          // ============================================================
          // CHECKBOX ENGAGEMENT
          // ============================================================
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