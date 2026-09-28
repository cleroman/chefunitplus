// ChefUnitPlus - Etape 1 : Compte
import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
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
          TextField(
            controller: state.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email *',
              hintText: 'exemple@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telephone *',
              hintText: '+24389XXXXXXX',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe * (min 6)',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: state.confirmPasswordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmation *',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ],
      ),
    );
  }
}