import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/register_controller.dart';
import '../../widgets/utils/pdf_picker.dart';
import 'verify_email_screen.dart';

const List<Map<String, dynamic>> kScoutRoles = [
  {'value': 'apprenant', 'label': 'Apprenant', 'desc': 'Suivre les formations', 'icon': Icons.school_outlined, 'color': Colors.blue},
  {'value': 'formateur', 'label': 'Formateur', 'desc': 'Enseigner et proposer', 'icon': Icons.cast_for_education, 'color': Colors.green},
  {'value': 'directeur', 'label': 'Directeur', 'desc': 'Gerer les formations', 'icon': Icons.business_center_outlined, 'color': Colors.orange},
];

const List<String> kScoutFunctions = [
  'Chef de groupe', 'Assistant chef de groupe',
  'Chef de patrouille', 'Assistant chef de patrouille',
  'Membre actif', 'Membre en formation',
  'Formateur', 'Directeur pedagogique',
  'Commissaire', 'Autre',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageCtrl = PageController();
  int _currentStep = 0;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPassword = false;

  String _role = 'apprenant';
  String? _scoutGroupId;
  final _regionCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  String? _scoutFunction;

  Uint8List? _photoBytes;
  String? _photoFileName;
  final _bioCtrl = TextEditingController();

  bool _acceptTerms = false;
  bool _acceptPrivacy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterController>().loadScoutGroups();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    _regionCtrl.dispose(); _districtCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep == 1) {
      if (_scoutGroupId == null) { _snack('Selectionnez un groupe', AppColors.warning); return; }
      if (_scoutFunction == null) { _snack('Selectionnez une fonction', AppColors.warning); return; }
      if (_regionCtrl.text.trim().isEmpty) { _snack('Region requise', AppColors.warning); return; }
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(_currentStep,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(_currentStep,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _submit() async {
    if (!_acceptTerms || !_acceptPrivacy) {
      _snack('Acceptez les conditions', AppColors.warning);
      return;
    }
    final ctrl = context.read<RegisterController>();
    final ok = await ctrl.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phone: _phoneCtrl.text.trim(),
      role: _role,
      scoutGroupId: _scoutGroupId!,
      region: _regionCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      scoutFunction: _scoutFunction!,
      photoBytes: _photoBytes,
      photoFileName: _photoFileName,
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: _emailCtrl.text.trim())));
    } else {
      _snack(ctrl.errorMessage ?? 'Erreur', AppColors.danger);
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await PdfPicker.pick();
    if (picked == null || !mounted) return;
    setState(() {
      _photoBytes = picked.bytes;
      _photoFileName = picked.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RegisterController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inscription Scout'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        leading: _currentStep > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep)
            : null,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _stepper(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [_step1(), _step2(), _step3(), _step4()],
              ),
            ),
            _navBar(ctrl),
          ],
        ),
      ),
    );
  }

  Widget _stepper() {
    final steps = ['Infos', 'Scout', 'Profil', 'CGU'];
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _stepCircle(i, steps[i]),
            if (i < steps.length - 1) Expanded(child: _stepLine(i)),
          ],
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label) {
    final done = _currentStep > step;
    final active = _currentStep == step;
    return Column(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: done ? AppColors.success : (active ? AppColors.mauve : Colors.grey.shade300),
          shape: BoxShape.circle,
        ),
        child: Center(child: done
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : Text('${step + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10,
        color: done || active ? AppColors.mauve : AppColors.textMuted,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
    ]);
  }

  Widget _stepLine(int step) => Container(
    height: 2,
    color: _currentStep > step ? AppColors.success : Colors.grey.shade300,
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );

  // ============ ETAPE 1 ============
  Widget _step1() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Informations personnelles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    const Text('Vos coordonnees de membre scout.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
    const SizedBox(height: 24),
    TextFormField(controller: _nameCtrl, textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(labelText: 'Nom complet', hintText: 'Ex : Jean Mukendi',
        prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
      validator: (v) => v == null || v.trim().length < 3 ? 'Au moins 3 caracteres' : null),
    const SizedBox(height: 16),
    TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email', hintText: 'Ex : jean@scout.cd',
        prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requis';
        if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(v.trim())) return 'Email invalide';
        return null;
      }),
    const SizedBox(height: 16),
    TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone,
      decoration: const InputDecoration(labelText: 'Telephone', hintText: 'Ex : +243 81 234 5678',
        prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
      validator: (v) => v == null || v.trim().length < 8 ? 'Trop court' : null),
    const SizedBox(height: 16),
    TextFormField(controller: _passwordCtrl, obscureText: !_showPassword, onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _showPassword = !_showPassword)),
        border: const OutlineInputBorder()),
      validator: (v) {
        if (v == null || v.length < 8) return 'Au moins 8 caracteres';
        if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Au moins 1 majuscule';
        if (!RegExp(r'[0-9]').hasMatch(v)) return 'Au moins 1 chiffre';
        return null;
      }),
    if (_passwordCtrl.text.isNotEmpty) ...[
      const SizedBox(height: 8),
      _passwordStrength(),
    ],
    const SizedBox(height: 16),
    TextFormField(controller: _confirmCtrl, obscureText: !_showPassword,
      decoration: const InputDecoration(labelText: 'Confirmer mot de passe',
        prefixIcon: Icon(Icons.check_circle_outline), border: OutlineInputBorder()),
      validator: (v) => v != _passwordCtrl.text ? 'Ne correspond pas' : null),
  ]);

  Widget _passwordStrength() {
    final pwd = _passwordCtrl.text;
    double score = 0;
    if (pwd.length >= 8) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score += 0.25;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(pwd)) score += 0.25;
    Color color = score < 0.5 ? AppColors.danger : (score < 0.75 ? AppColors.warning : AppColors.success);
    String label = score < 0.5 ? 'Faible' : (score < 0.75 ? 'Moyen' : 'Fort');
    return Row(children: [
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: score, minHeight: 6,
          backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color)))),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
    ]);
  }

  // ============ ETAPE 2 ============
  Widget _step2() {
    final ctrl = context.watch<RegisterController>();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Informations scout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Votre role et votre groupe scout.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      const SizedBox(height: 24),
      const Text('Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ...kScoutRoles.map((r) {
        final selected = _role == r['value'];
        return Padding(padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => setState(() => _role = r['value'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? (r['color'] as Color).withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? r['color'] as Color : AppColors.divider, width: selected ? 2 : 1),
              ),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: (r['color'] as Color).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(r['icon'] as IconData, color: r['color'] as Color, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['label'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(r['desc'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ])),
                if (selected) Icon(Icons.check_circle, color: r['color'] as Color),
              ]),
            ),
          ));
      }),
      const SizedBox(height: 20),
      const Text('Groupe scout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      if (ctrl.isLoadingGroups)
        const Center(child: CircularProgressIndicator())
      else if (ctrl.scoutGroups.isEmpty)
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Text('Aucun groupe disponible', style: TextStyle(fontSize: 12, color: AppColors.warning)))
      else
        DropdownButtonFormField<String>(
          initialValue: _scoutGroupId, isExpanded: true,
          decoration: const InputDecoration(labelText: 'Choisir un groupe',
            prefixIcon: Icon(Icons.groups_outlined), border: OutlineInputBorder()),
          items: ctrl.scoutGroups.map((g) {
            final id = (g['id'] ?? g['_id'] ?? '').toString();
            final name = g['name'] ?? 'Groupe';
            return DropdownMenuItem<String>(value: id, child: Text(name));
          }).toList(),
          onChanged: (v) => setState(() => _scoutGroupId = v),
        ),
      const SizedBox(height: 16),
      TextFormField(controller: _regionCtrl,
        decoration: const InputDecoration(labelText: 'Region', hintText: 'Ex : Kinshasa',
          prefixIcon: Icon(Icons.location_on_outlined), border: OutlineInputBorder())),
      const SizedBox(height: 16),
      TextFormField(controller: _districtCtrl,
        decoration: const InputDecoration(labelText: 'District', hintText: 'Ex : Gombe',
          prefixIcon: Icon(Icons.map_outlined), border: OutlineInputBorder())),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue: _scoutFunction, isExpanded: true,
        decoration: const InputDecoration(labelText: 'Fonction scout',
          prefixIcon: Icon(Icons.badge_outlined), border: OutlineInputBorder()),
        items: kScoutFunctions.map((f) => DropdownMenuItem<String>(value: f, child: Text(f))).toList(),
        onChanged: (v) => setState(() => _scoutFunction = v),
      ),
    ]);
  }

  // ============ ETAPE 3 ============
  Widget _step3() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Photo & Bio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    const Text('Optionnel - vous pourrez modifier plus tard.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
    const SizedBox(height: 24),
    Center(child: GestureDetector(onTap: _pickPhoto, child: Stack(children: [
      Container(width: 120, height: 120,
        decoration: BoxDecoration(
          color: AppColors.mauve.withValues(alpha: 0.1), shape: BoxShape.circle,
          border: Border.all(color: AppColors.mauve, width: 2),
          image: _photoBytes != null ? DecorationImage(image: MemoryImage(_photoBytes!), fit: BoxFit.cover) : null,
        ),
        child: _photoBytes == null ? const Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.mauve) : null),
      Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: AppColors.mauve, shape: BoxShape.circle),
        child: const Icon(Icons.edit, color: Colors.white, size: 16))),
    ]))),
    const SizedBox(height: 32),
    TextFormField(controller: _bioCtrl, maxLines: 4, maxLength: 200,
      decoration: const InputDecoration(labelText: 'Bio (optionnel)',
        hintText: 'Quelques mots sur vous...',
        prefixIcon: Icon(Icons.description_outlined),
        border: OutlineInputBorder(), alignLabelWithHint: true)),
  ]);

  // ============ ETAPE 4 ============
  Widget _step4() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Conditions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    const Text('Derniere etape avant de creer votre compte.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
    const SizedBox(height: 24),
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recapitulatif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _recap('Nom', _nameCtrl.text),
        _recap('Email', _emailCtrl.text),
        _recap('Telephone', _phoneCtrl.text),
        _recap('Role', kScoutRoles.firstWhere((r) => r['value'] == _role, orElse: () => {'label': _role})['label'] as String),
        _recap('Fonction', _scoutFunction ?? '-'),
        _recap('Region', _regionCtrl.text),
        _recap('District', _districtCtrl.text.isEmpty ? '-' : _districtCtrl.text),
      ])),
    const SizedBox(height: 24),
    CheckboxListTile(value: _acceptTerms, onChanged: (v) => setState(() => _acceptTerms = v ?? false),
      title: const Text("J'accepte les conditions d'utilisation", style: TextStyle(fontSize: 13)),
      controlAffinity: ListTileControlAffinity.leading, activeColor: AppColors.mauve),
    CheckboxListTile(value: _acceptPrivacy, onChanged: (v) => setState(() => _acceptPrivacy = v ?? false),
      title: const Text('J\'accepte la politique de confidentialite', style: TextStyle(fontSize: 13)),
      controlAffinity: ListTileControlAffinity.leading, activeColor: AppColors.mauve),
  ]);

  Widget _recap(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
      Expanded(child: Text(value.isEmpty ? '-' : value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _navBar(RegisterController ctrl) {
    return Container(padding: const EdgeInsets.all(16), color: Colors.white,
      child: SafeArea(child: Row(children: [
        if (_currentStep > 0)
          Expanded(child: OutlinedButton(
            onPressed: _prevStep,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: AppColors.mauve,
              side: const BorderSide(color: AppColors.mauve)),
            child: const Text('Retour'))),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(flex: 2, child: ElevatedButton(
          onPressed: ctrl.isLoading ? null : (_currentStep < 3 ? _nextStep : _submit),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mauve, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14)),
          child: ctrl.isLoading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(_currentStep < 3 ? 'Suivant' : 'Creer mon compte'))),
      ])),
    );
  }
}