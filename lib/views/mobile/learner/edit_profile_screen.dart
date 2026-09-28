// =============================================================
// ChefUnitPlus - EditProfileScreen COMPLET
// Route : /editprofile
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameCtrl;
  late TextEditingController _prenomCtrl;
  late TextEditingController _postNomCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _lieuNaissanceCtrl;
  late TextEditingController _adresseCtrl;
  late TextEditingController _totemCtrl;
  late TextEditingController _avatarUrlCtrl;

  UserSexe? _sexe;
  DateTime? _dateNaissance;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = context.read<AuthController>().currentUser;

    _fullNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _prenomCtrl = TextEditingController(text: user?.prenom ?? '');
    _postNomCtrl = TextEditingController(text: user?.postNom ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _lieuNaissanceCtrl = TextEditingController(text: user?.lieuNaissance ?? '');
    _adresseCtrl = TextEditingController(text: user?.adresse ?? '');
    _totemCtrl = TextEditingController(text: user?.totem ?? '');
    _avatarUrlCtrl = TextEditingController(text: user?.photoUrl ?? '');

    _sexe = user?.sexe;
    _dateNaissance = user?.dateNaissance;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _prenomCtrl.dispose();
    _postNomCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _lieuNaissanceCtrl.dispose();
    _adresseCtrl.dispose();
    _totemCtrl.dispose();
    _avatarUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Enregistrer',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),

          _sectionTitle('Identite', Icons.person_outline),

          TextFormField(
            controller: _fullNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nom complet *',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nom complet requis';
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _prenomCtrl,
            decoration: const InputDecoration(
              labelText: 'Prenom *',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Prenom requis';
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _postNomCtrl,
            decoration: const InputDecoration(
              labelText: 'Post-nom',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<UserSexe>(
            initialValue: _sexe,
            decoration: const InputDecoration(
              labelText: 'Sexe',
              prefixIcon: Icon(Icons.wc_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: UserSexe.masculin, child: Text('Masculin')),
              DropdownMenuItem(value: UserSexe.feminin, child: Text('Feminin')),
            ],
            onChanged: (v) => setState(() => _sexe = v),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: _pickDateNaissance,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(),
              ),
              child: Text(
                _dateNaissance != null
                    ? '${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}'
                    : 'Selectionner une date',
                style: TextStyle(
                  color: _dateNaissance != null ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _lieuNaissanceCtrl,
            decoration: const InputDecoration(
              labelText: 'Lieu de naissance',
              prefixIcon: Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Contact', Icons.contact_phone_outlined),

          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telephone *',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Telephone requis';
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _emailCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              helperText: 'L\'email ne peut pas etre modifie',
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _adresseCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Informations Scout', Icons.forest_outlined),

          TextFormField(
            controller: _totemCtrl,
            decoration: const InputDecoration(
              labelText: 'Totem',
              prefixIcon: Icon(Icons.local_florist_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _avatarUrlCtrl,
            decoration: const InputDecoration(
              labelText: 'URL Avatar',
              prefixIcon: Icon(Icons.image_outlined),
              border: OutlineInputBorder(),
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mauve,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mauve, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.mauve,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mauve.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.mauve),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Modifiez toutes vos informations personnelles.',
              style: TextStyle(fontSize: 13, color: AppColors.mauve),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateNaissance() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateNaissance = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final auth = context.read<AuthController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final ok = await auth.updateProfile(
        fullName: _fullNameCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        postNom: _postNomCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        sexe: _sexe?.short,
        dateNaissance: _dateNaissance,
        lieuNaissance: _lieuNaissanceCtrl.text.trim(),
        adresse: _adresseCtrl.text.trim(),
        totem: _totemCtrl.text.trim(),
        avatarUrl: _avatarUrlCtrl.text.trim(),
      );

      if (!mounted) return;

      if (ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profil mis a jour'),
            backgroundColor: AppColors.success,
          ),
        );
        navigator.pop(true);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Erreur'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}