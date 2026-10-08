// ChefUnitPlus - Etape 2 : Identite (avec photo)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/core/utils/formatters.dart';
import 'package:chefunitplus/core/utils/validators.dart';
import 'package:chefunitplus/widgets/common/custom_text_field.dart';
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
          // ============================================================
          // PHOTO D'IDENTITE
          // ============================================================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mauveSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: AppColors.mauve, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Photo d\'identite',
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: state.photoBytes != null
                          ? AppColors.success
                          : AppColors.divider,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: state.photoBytes != null
                        ? Image.memory(state.photoBytes!, fit: BoxFit.cover)
                        : const Icon(Icons.person,
                            size: 80, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet<ImageSource>(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt, color: AppColors.mauve),
                              title: const Text('Prendre une photo'),
                              subtitle: const Text('Utiliser la camera du telephone'),
                              onTap: () {
                                Navigator.pop(ctx);
                                state.pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library, color: AppColors.mauve),
                              title: const Text('Importer depuis la galerie'),
                              subtitle: const Text('Choisir une photo existante'),
                              onTap: () {
                                Navigator.pop(ctx);
                                state.pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text('Ajouter une photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mauve,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                if (state.photoBytes != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        state.photoFileName ?? 'Photo selectionnee',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ============================================================
          // INFORMATIONS PERSONNELLES
          // ============================================================
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
          CustomTextField(
            label: 'Post-nom *',
            hint: 'Ex : DUPONT',
            controller: state.postNomCtrl,
            icon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Post-nom'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Prenom *',
            hint: 'Ex : Jean',
            controller: state.prenomCtrl,
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Prenom'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: '2eme prenom (optionnel)',
            hint: 'Ex : Marie',
            controller: state.prenom2Ctrl,
            icon: Icons.person_add_outlined,
            textCapitalization: TextCapitalization.words,
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
              decoration: InputDecoration(
                labelText: 'Date de naissance *',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                errorText: state.dateNaissance == null
                    ? 'La date de naissance est obligatoire'
                    : null,
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
          CustomTextField(
            label: 'Lieu de naissance *',
            hint: 'Ex : Kinshasa',
            controller: state.lieuNaissanceCtrl,
            icon: Icons.location_city_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, fieldName: 'Lieu de naissance'),
          ),
        ],
      ),
    );
  }
}