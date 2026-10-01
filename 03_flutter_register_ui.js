// =============================================================
// ChefUnitPlus - Flutter : Ecran d'inscription multi-etapes
// 7 etapes Material Design avec Stepper
// =============================================================

const fs = require('fs');
const path = require('path');

const BASE = process.cwd();

console.log('');
console.log('===========================================================');
console.log('  ChefUnitPlus - Inscription Scout UI');
console.log('===========================================================');
console.log('');

function w(rel, content) {
    const full = path.join(BASE, rel);
    const dir = path.dirname(full);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(full, content, 'utf8');
    console.log('  [+] ' + rel);
}

// =============================================================
// 1. ECRAN D'INSCRIPTION MULTI-ETAPES
// =============================================================
w('lib/views/auth/register_screen.dart', `// =============================================================
// ChefUnitPlus - RegisterScreen (Inscription Scout)
// Formulaire multi-etapes Material Design
// =============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/emergency_contact.dart';
import '../../models/registration_data.dart';
import '../../models/scout_camp.dart';
import '../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _data = RegistrationData();

  // Controleurs
  final _nomCtrl = TextEditingController();
  final _postNomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _dateNaissCtrl = TextEditingController();
  final _lieuNaissCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _communeCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _avenueCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _groupeCtrl = TextEditingController();
  final _affiliationCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _associationCtrl = TextEditingController();
  final _dateEntreeCtrl = TextEditingController();
  final _fonctionCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _niveauCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nomCtrl.dispose(); _postNomCtrl.dispose(); _prenomCtrl.dispose();
    _dateNaissCtrl.dispose(); _lieuNaissCtrl.dispose();
    _phoneCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    _provinceCtrl.dispose(); _villeCtrl.dispose();
    _communeCtrl.dispose(); _quartierCtrl.dispose();
    _avenueCtrl.dispose(); _numeroCtrl.dispose();
    _groupeCtrl.dispose(); _affiliationCtrl.dispose();
    _districtCtrl.dispose(); _associationCtrl.dispose();
    _dateEntreeCtrl.dispose(); _fonctionCtrl.dispose();
    _professionCtrl.dispose(); _niveauCtrl.dispose();
    _medicalCtrl.dispose();
    super.dispose();
  }

  // =============================================================
  // Validations par etape
  // =============================================================
  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (_nomCtrl.text.trim().length < 2) return 'Nom requis (min 2)';
        if (_postNomCtrl.text.trim().length < 2) return 'Post-nom requis';
        if (_prenomCtrl.text.trim().length < 2) return 'Prenom requis';
        if (_dateNaissCtrl.text.trim().isEmpty) return 'Date de naissance requise';
        if (_lieuNaissCtrl.text.trim().isEmpty) return 'Lieu de naissance requis';
        return null;
      case 1:
        if (_phoneCtrl.text.trim().length < 9) return 'Telephone invalide';
        if (!_emailCtrl.text.contains('@')) return 'Email invalide';
        if (_passwordCtrl.text.length < 6) return 'Mot de passe min 6';
        if (_passwordCtrl.text != _confirmCtrl.text) return 'Mots de passe differents';
        return null;
      case 2:
        if (_provinceCtrl.text.trim().isEmpty) return 'Province requise';
        if (_villeCtrl.text.trim().isEmpty) return 'Ville requise';
        if (_communeCtrl.text.trim().isEmpty) return 'Commune requise';
        if (_quartierCtrl.text.trim().isEmpty) return 'Quartier requis';
        if (_avenueCtrl.text.trim().isEmpty) return 'Avenue requise';
        if (_numeroCtrl.text.trim().isEmpty) return 'Numero requis';
        return null;
      case 3:
        if (_groupeCtrl.text.trim().isEmpty) return 'Groupe scout requis';
        if (_affiliationCtrl.text.trim().isEmpty) return 'N affiliation requis';
        if (_districtCtrl.text.trim().isEmpty) return 'District requis';
        if (_dateEntreeCtrl.text.trim().isEmpty) return 'Date d entree requise';
        if (_fonctionCtrl.text.trim().isEmpty) return 'Fonction requise';
        if (_niveauCtrl.text.trim().isEmpty) return 'Niveau d etude requis';
        return null;
      case 4:
        if (_data.camps.isEmpty) return 'Ajoutez au moins 1 camp de formation';
        return null;
      case 5:
        if (_data.emergencyContacts.length < 2) {
          return 'Ajoutez au moins 2 contacts d urgence';
        }
        for (final c in _data.emergencyContacts) {
          if (c.nom.trim().isEmpty) return 'Nom du contact requis';
          if (c.telephone.trim().isEmpty) return 'Telephone du contact requis';
        }
        return null;
      case 6:
        if (!_data.engagementAccepte) return 'Vous devez accepter l engagement';
        return null;
      default:
        return null;
    }
  }

  void _next() {
    final error = _validateStep(_currentStep);
    if (error != null) {
      SnackbarHelper.error(context, error);
      return;
    }
    if (_currentStep < 6) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _previous() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // =============================================================
  // Soumission finale
  // =============================================================
  Future<void> _submit() async {
    setState(() => _loading = true);

    // Copier les donnees
    _data.nom = _nomCtrl.text.trim();
    _data.postNom = _postNomCtrl.text.trim();
    _data.prenom = _prenomCtrl.text.trim();
    _data.dateNaissance = _dateNaissCtrl.text.trim();
    _data.lieuNaissance = _lieuNaissCtrl.text.trim();
    _data.telephone = _phoneCtrl.text.trim();
    _data.email = _emailCtrl.text.trim().toLowerCase();
    _data.password = _passwordCtrl.text;
    _data.province = _provinceCtrl.text.trim();
    _data.ville = _villeCtrl.text.trim();
    _data.commune = _communeCtrl.text.trim();
    _data.quartier = _quartierCtrl.text.trim();
    _data.avenue = _avenueCtrl.text.trim();
    _data.numero = _numeroCtrl.text.trim();
    _data.groupeScout = _groupeCtrl.text.trim();
    _data.numeroAffiliation = _affiliationCtrl.text.trim();
    _data.district = _districtCtrl.text.trim();
    _data.association = _associationCtrl.text.trim();
    _data.dateEntreeScout = _dateEntreeCtrl.text.trim();
    _data.fonction = _fonctionCtrl.text.trim();
    _data.profession = _professionCtrl.text.trim();
    _data.niveauEtude = _niveauCtrl.text.trim();
    _data.antecedentsMedicaux = _medicalCtrl.text.trim();

    final auth = context.read<AuthController>();
    final ok = await auth.register(_data);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      SnackbarHelper.success(context, 'Inscription reussie !');
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.homeForRole(auth.currentUser!.role.name),
      );
    } else {
      SnackbarHelper.error(
        context,
        auth.errorMessage ?? 'Erreur lors de l inscription',
      );
    }
  }

  // =============================================================
  // BUILD
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Inscription (${_currentStep + 1}/7)'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barre de progression
          LinearProgressIndicator(
            value: (_currentStep + 1) / 7,
            backgroundColor: AppColors.mauveSoft,
            valueColor: const AlwaysStoppedAnimation(AppColors.mauve),
            minHeight: 4,
          ),

          // Contenu
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              physics: const ClampingScrollPhysics(),
              onStepTapped: (i) {
                if (i < _currentStep) setState(() => _currentStep = i);
              },
              onStepContinue: _next,
              onStepCancel: _previous,
              controlsBuilder: (context, details) {
                final isLast = _currentStep == 6;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Precedent'),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLast
                                ? AppColors.success
                                : AppColors.mauve,
                          ),
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(isLast
                                  ? Icons.check
                                  : Icons.arrow_forward),
                          label: Text(isLast
                              ? 'Terminer l inscription'
                              : 'Suivant'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                // ============================================
                // ETAPE 0 : Identite
                // ============================================
                Step(
                  title: const Text('Identite'),
                  subtitle: const Text('Nom, sexe, naissance'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: Column(
                    children: [
                      _field(_nomCtrl, 'Nom *', Icons.person_outline),
                      const SizedBox(height: 12),
                      _field(_postNomCtrl, 'Post-nom *', Icons.person_outline),
                      const SizedBox(height: 12),
                      _field(_prenomCtrl, 'Prenom *', Icons.person_outline),
                      const SizedBox(height: 12),
                      _dropdownSexe(),
                      const SizedBox(height: 12),
                      _datePicker(
                        _dateNaissCtrl,
                        'Date de naissance *',
                        Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _lieuNaissCtrl,
                        'Lieu de naissance *',
                        Icons.location_on_outlined,
                      ),
                    ],
                  ),
                ),

                // ============================================
                // ETAPE 1 : Contact
                // ============================================
                Step(
                  title: const Text('Contact'),
                  subtitle: const Text('Telephone, email, mot de passe'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content: Column(
                    children: [
                      _field(
                        _phoneCtrl,
                        'Telephone *',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        hint: '243891234567',
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _emailCtrl,
                        'Email *',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _passwordField(
                        _passwordCtrl,
                        'Mot de passe *',
                        Icons.lock_outline,
                      ),
                      const SizedBox(height: 12),
                      _passwordField(
                        _confirmCtrl,
                        'Confirmer mot de passe *',
                        Icons.lock_outline,
                      ),
                    ],
                  ),
                ),

                // ============================================
                // ETAPE 2 : Adresse
                // ============================================
                Step(
                  title: const Text('Adresse'),
                  subtitle: const Text('Province, ville, commune'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                  content: Column(
                    children: [
                      _field(_provinceCtrl, 'Province *', Icons.map_outlined),
                      const SizedBox(height: 12),
                      _field(_villeCtrl, 'Ville *', Icons.location_city_outlined),
                      const SizedBox(height: 12),
                      _field(_communeCtrl, 'Commune *', Icons.location_city_outlined),
                      const SizedBox(height: 12),
                      _field(_quartierCtrl, 'Quartier *', Icons.home_outlined),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _field(_avenueCtrl, 'Avenue *',
                                Icons.signpost_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(_numeroCtrl, 'Numero *',
                                Icons.tag),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ============================================
                // ETAPE 3 : Scout
                // ============================================
                Step(
                  title: const Text('Scout'),
                  subtitle: const Text('Groupe, branche, fonction'),
                  isActive: _currentStep >= 3,
                  state: _currentStep > 3
                      ? StepState.complete
                      : StepState.indexed,
                  content: Column(
                    children: [
                      _field(_groupeCtrl, 'Groupe scout *',
                          Icons.groups_outlined),
                      const SizedBox(height: 12),
                      _field(_affiliationCtrl, 'Numero d affiliation *',
                          Icons.confirmation_number_outlined),
                      const SizedBox(height: 12),
                      _field(_districtCtrl, 'District *',
                          Icons.location_city_outlined),
                      const SizedBox(height: 12),
                      _field(_associationCtrl, 'Association',
                          Icons.business_outlined),
                      const SizedBox(height: 12),
                      _dropdownBranche(),
                      const SizedBox(height: 12),
                      _datePicker(
                        _dateEntreeCtrl,
                        'Date entree dans le mouvement *',
                        Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: 12),
                      _field(_fonctionCtrl, 'Fonction *',
                          Icons.badge_outlined),
                      const SizedBox(height: 12),
                      _field(_professionCtrl, 'Profession',
                          Icons.work_outline),
                      const SizedBox(height: 12),
                      _field(_niveauCtrl, 'Niveau d etude *',
                          Icons.school_outlined),
                      const SizedBox(height: 12),
                      _field(
                        _medicalCtrl,
                        'Antecedents medicaux',
                        Icons.medical_information_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                // ============================================
                // ETAPE 4 : Camps de formation
                // ============================================
                Step(
                  title: const Text('Camps'),
                  subtitle: const Text('Camps de formation suivis'),
                  isActive: _currentStep >= 4,
                  state: _currentStep > 4
                      ? StepState.complete
                      : StepState.indexed,
                  content: _campsSection(),
                ),

                // ============================================
                // ETAPE 5 : Contacts d'urgence
                // ============================================
                Step(
                  title: const Text('Urgence'),
                  subtitle: const Text('Contacts en cas d urgence'),
                  isActive: _currentStep >= 5,
                  state: _currentStep > 5
                      ? StepState.complete
                      : StepState.indexed,
                  content: _emergencySection(),
                ),

                // ============================================
                // ETAPE 6 : Engagement
                // ============================================
                Step(
                  title: const Text('Engagement'),
                  subtitle: const Text('Acceptation des conditions'),
                  isActive: _currentStep >= 6,
                  state: StepState.indexed,
                  content: _engagementSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // WIDGETS DE CHAMP
  // =============================================================
  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.mauve),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.mauve, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _passwordField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: ctrl,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.mauve),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.mauve, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _datePicker(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1940),
          lastDate: DateTime.now(),
          locale: const Locale('fr', 'FR'),
        );
        if (picked != null) {
          ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.mauve),
        suffixIcon: const Icon(Icons.calendar_month, color: AppColors.mauve),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.mauve, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _dropdownSexe() {
    return DropdownButtonFormField<String>(
      initialValue: _data.sexe,
      decoration: const InputDecoration(
        labelText: 'Sexe *',
        prefixIcon: Icon(Icons.wc_outlined, color: AppColors.mauve),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem(value: 'homme', child: Text('Homme')),
        DropdownMenuItem(value: 'femme', child: Text('Femme')),
      ],
      onChanged: (v) => setState(() => _data.sexe = v ?? 'homme'),
    );
  }

  Widget _dropdownBranche() {
    return DropdownButtonFormField<String>(
      initialValue: _data.branche,
      decoration: const InputDecoration(
        labelText: 'Branche *',
        prefixIcon: Icon(Icons.tree_outlined, color: AppColors.mauve),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem(value: 'meute', child: Text('Meute (Louveteaux)')),
        DropdownMenuItem(value: 'troupe', child: Text('Troupe (Eclaireurs)')),
        DropdownMenuItem(
            value: 'compagnie', child: Text('Compagnie (Pionniers)')),
        DropdownMenuItem(value: 'clan', child: Text('Clan (Routiers)')),
      ],
      onChanged: (v) => setState(() => _data.branche = v ?? 'meute'),
    );
  }

  // =============================================================
  // SECTION CAMPS
  // =============================================================
  Widget _campsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Camps de formation suivis depuis votre entree dans le mouvement',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),

        // Liste des camps
        ..._data.camps.asMap().entries.map((entry) {
          final i = entry.key;
          final camp = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.kakiSoft,
                child: Icon(Icons.camping, color: AppColors.kakiDark),
              ),
              title: Text(camp.nomCamp),
              subtitle: Text(
                '${camp.annee ?? "N/A"}${camp.lieu != null ? " - ${camp.lieu}" : ""}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.danger),
                onPressed: () => setState(() => _data.camps.removeAt(i)),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addCamp,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un camp'),
        ),
      ],
    );
  }

  Future<void> _addCamp() async {
    final nomCtrl = TextEditingController();
    final anneeCtrl = TextEditingController();
    final lieuCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau camp de formation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom du camp *',
                  hintText: 'Ex: Camp Training 2024',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: anneeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Annee'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lieuCtrl,
                decoration: const InputDecoration(labelText: 'Lieu'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true && nomCtrl.text.trim().isNotEmpty) {
      setState(() {
        _data.camps.add(ScoutCamp(
          nomCamp: nomCtrl.text.trim(),
          annee: int.tryParse(anneeCtrl.text.trim()),
          lieu: lieuCtrl.text.trim().isEmpty ? null : lieuCtrl.text.trim(),
          description:
              descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        ));
      });
    }
  }

  // =============================================================
  // SECTION CONTACTS D'URGENCE
  // =============================================================
  Widget _emergencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Personnes a prevenir en cas d urgence (minimum 2)',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),

        ..._data.emergencyContacts.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.dangerSoft,
                child: Icon(Icons.emergency, color: AppColors.dangerDark),
              ),
              title: Text('${c.nom} ${c.prenom ?? ""}'),
              subtitle: Text(c.telephone),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.danger),
                onPressed: () =>
                    setState(() => _data.emergencyContacts.removeAt(i)),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addEmergency,
          icon: const Icon(Icons.person_add),
          label: Text(
            'Ajouter un contact (${_data.emergencyContacts.length}/2 min)',
          ),
        ),
      ],
    );
  }

  Future<void> _addEmergency() async {
    final nomCtrl = TextEditingController();
    final postCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final adrCtrl = TextEditingController();
    final relCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact d urgence'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: postCtrl,
                decoration: const InputDecoration(labelText: 'Post-nom'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: prenomCtrl,
                decoration: const InputDecoration(labelText: 'Prenom'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: telCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telephone *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: adrCtrl,
                decoration: const InputDecoration(labelText: 'Adresse complete'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: relCtrl,
                decoration: const InputDecoration(
                  labelText: 'Relation (pere, mere, oncle...)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true && nomCtrl.text.trim().isNotEmpty && telCtrl.text.trim().isNotEmpty) {
      setState(() {
        _data.emergencyContacts.add(EmergencyContact(
          nom: nomCtrl.text.trim(),
          postNom: postCtrl.text.trim().isEmpty ? null : postCtrl.text.trim(),
          prenom: prenomCtrl.text.trim().isEmpty ? null : prenomCtrl.text.trim(),
          telephone: telCtrl.text.trim(),
          adresse: adrCtrl.text.trim().isEmpty ? null : adrCtrl.text.trim(),
          relation: relCtrl.text.trim().isEmpty ? null : relCtrl.text.trim(),
        ));
      });
    }
  }

  // =============================================================
  // SECTION ENGAGEMENT
  // =============================================================
  Widget _engagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mauveSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mauve),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SUR MON HONNEUR, JE M ENGAGE A RESPECTER CES CONDITIONS :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mauveDark,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '1. Amener mon materiel de camping\n'
                '2. Avoir participe avec succes au camp training precedent (attestation)\n'
                '3. Participer aux frais du camp\n'
                '4. Avoir l autorisation de mon groupe scout\n'
                '5. Avoir un uniforme correct\n'
                '6. Avoir un cahier correct et de quoi ecrire\n'
                '7. Continuer a servir le scoutisme en tant que membre actif apres le stage\n'
                '8. Se soumettre aux conditions d evaluation et de suivi retenues',
                style: TextStyle(height: 1.6, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _data.engagementAccepte,
          onChanged: (v) =>
              setState(() => _data.engagementAccepte = v ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.success,
          title: const Text(
            'J accepte les conditions ci-dessus',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
`);

// =============================================================
// 2. LOGIN SCREEN (avec placeholders moiscout / ********)
// =============================================================
w('lib/views/auth/login_screen.dart', `// =============================================================
// ChefUnitPlus - LoginScreen
// Connexion avec identifiants scout
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.login(
      email: _email.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;

    if (success) {
      SnackbarHelper.success(context, 'Connexion reussie');
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.homeForRole(auth.currentUser!.role.name),
      );
    } else {
      SnackbarHelper.error(
        context,
        auth.errorMessage ?? 'Identifiants invalides',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.mauveSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.scouts,
                      size: 64,
                      color: AppColors.mauve,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nom
                const Text(
                  'ChefUnitPlus',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mauveDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Formez les leaders scouts de demain',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 48),

                // Email
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'moiscout (Email)',
                    hintText: 'exemple@scout.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: '******** (Mot de passe)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.forgotPassword,
                    ),
                    child: const Text('Mot de passe oublie ?'),
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mauve,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore de compte ?',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                      child: const Text(
                        'S inscrire',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
`);

console.log('');
console.log('===========================================================');
console.log('  UI INSCRIPTION + LOGIN PRETS !');
console.log('===========================================================');
console.log('');
console.log('Fichiers crees :');
console.log('  - lib/views/auth/register_screen.dart (7 etapes)');
console.log('  - lib/views/auth/login_screen.dart (moiscout / ********)');
console.log('');
console.log('Etape suivante : flutter analyze puis flutter run');
console.log('');