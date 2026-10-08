// ChefUnitPlus - Etape 3 : Adresse
import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/core/utils/validators.dart';
import 'package:chefunitplus/widgets/common/custom_text_field.dart';
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
          CustomTextField(
            label: 'Province *',
            hint: 'Ex : Kinshasa',
            controller: state.provinceCtrl,
            icon: Icons.map_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Province'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Ville *',
            hint: 'Ex : Kinshasa',
            controller: state.villeCtrl,
            icon: Icons.location_city_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Ville'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Commune *',
            hint: 'Ex : Gombe',
            controller: state.communeCtrl,
            icon: Icons.location_on_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Commune'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Quartier *',
            hint: 'Ex : Centre',
            controller: state.quartierCtrl,
            icon: Icons.home_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Quartier'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Avenue *',
            hint: 'Ex : Avenue de la Paix',
            controller: state.avenueCtrl,
            icon: Icons.signpost_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Avenue'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Numero *',
            hint: 'Ex : 123',
            controller: state.numeroCtrl,
            icon: Icons.tag,
            keyboardType: TextInputType.number,
            validator: (v) => Validators.required(v, fieldName: 'Numero'),
          ),
        ],
      ),
    );
  }
}