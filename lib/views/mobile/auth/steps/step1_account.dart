// ChefUnitPlus - Etape 1 : Compte
import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/core/utils/validators.dart';
import 'package:chefunitplus/widgets/common/custom_text_field.dart';
import '../register_wizard_screen.dart';

class Step1Account extends StatelessWidget {
  final RegisterWizardScreenState state;
  const Step1Account({super.key, required this.state});

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
                Icon(Icons.lock_outline, color: AppColors.mauve, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Creez vos identifiants de connexion',
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
          CustomTextField(
            label: 'Email *',
            hint: 'exemple@email.com',
            controller: state.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email_outlined,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Telephone *',
            hint: '+24389XXXXXXX',
            controller: state.phoneCtrl,
            keyboardType: TextInputType.phone,
            icon: Icons.phone_outlined,
            validator: Validators.phone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Mot de passe * (min 6)',
            hint: 'Minimum 6 caracteres',
            controller: state.passwordCtrl,
            obscure: true,
            icon: Icons.lock_outline,
            validator: Validators.password,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Confirmation *',
            hint: 'Retapez le mot de passe',
            controller: state.confirmPasswordCtrl,
            obscure: true,
            icon: Icons.lock_outline,
            validator: (value) => Validators.confirmPassword(
              value,
              state.passwordCtrl.text,
            ),
          ),
        ],
      ),
    );
  }
}