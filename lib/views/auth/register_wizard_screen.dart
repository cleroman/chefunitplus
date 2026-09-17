// =============================================================
// ChefUnitPlus - Wizard d'inscription (6 Ã©tapes)
// Fichier complet et corrigÃ© - Version finale
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chefunitplus/controllers/auth_controller.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/core/routes/app_routes.dart';
import 'package:chefunitplus/core/utils/snackbar_helper.dart';
import 'package:chefunitplus/models/emergency_contact.dart';
import 'package:chefunitplus/models/user_details.dart';
import 'package:chefunitplus/models/scout_camp.dart';
import 'package:chefunitplus/services/register_service.dart';
import 'package:chefunitplus/controllers/scout_group_controller.dart';

import 'steps/step1_account.dart';
import 'steps/step2_identity.dart';
import 'steps/step3_address.dart';
import 'steps/step4_scout.dart';
import 'steps/step5_pro_health.dart';
import 'steps/step6_engagement.dart';

class RegisterWizardScreen extends StatefulWidget {
  const RegisterWizardScreen({super.key});

  @override
  State<RegisterWizardScreen> createState() => RegisterWizardScreenState();
}

class RegisterWizardScreenState extends State<RegisterWizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<ScoutGroupController>().loadPublic();
      } catch (_) {}
    });
  }
  int currentStep = 0;
  bool isSubmitting = false;
  String? errorMessage;

  // ===== ETAPE 1 : Compte =====
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // ===== ETAPE 2 : Identite =====
  final postNomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final prenom2Ctrl = TextEditingController();
  String sexe = 'homme';
  DateTime? dateNaissance;
  final lieuNaissanceCtrl = TextEditingController();

  // ===== ETAPE 3 : Adresse =====
  final provinceCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  final communeCtrl = TextEditingController();
  final quartierCtrl = TextEditingController();
  final avenueCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();

  // ===== ETAPE 4 : Scout =====
  final groupeScoutCtrl = TextEditingController();
  String? groupeScoutId;
  final numeroAffiliationCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final regionCtrl = TextEditingController();
  final associationCtrl = TextEditingController();
  ScoutBranch branche = ScoutBranch.troupe;
  DateTime? dateEntreeScout;
  final fonctionScoutCtrl = TextEditingController();

  // ===== ETAPE 5 : Pro & Sante =====
  final professionCtrl = TextEditingController();
  final antecedentsCtrl = TextEditingController();
  final List<ScoutCamp> camps = [];
  final List<EmergencyContact> contactsUrgence = [];

  // ===== ETAPE 6 : Engagement =====
  bool engagementAccepte = false;

  static const List<String> _titles = [
    'Compte',
    'Identite',
    'Adresse',
    'Scout',
    'Pro & Sante',
    'Engagement',
  ];

  @override
  void dispose() {
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    postNomCtrl.dispose();
    prenomCtrl.dispose();
    prenom2Ctrl.dispose();
    lieuNaissanceCtrl.dispose();
    provinceCtrl.dispose();
    villeCtrl.dispose();
    communeCtrl.dispose();
    quartierCtrl.dispose();
    avenueCtrl.dispose();
    numeroCtrl.dispose();
    groupeScoutCtrl.dispose();
    numeroAffiliationCtrl.dispose();
    districtCtrl.dispose();
    regionCtrl.dispose();
    associationCtrl.dispose();
    fonctionScoutCtrl.dispose();
    professionCtrl.dispose();
    antecedentsCtrl.dispose();
    super.dispose();
  }

  // ===========================================================
  // Navigation entre les etapes
  // ===========================================================
  void refresh() {
    if (mounted) setState(() {});
  }

  void _next() {
    if (currentStep < 5) setState(() => currentStep++);
  }

  void _prev() {
    if (currentStep > 0) setState(() => currentStep--);
  }

  // ===========================================================
  // DEBUG (affiche l'etat des controllers)
  // ===========================================================
  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange),
            SizedBox(width: 8),
            Text('Debug Controllers'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _debugRow('Etape', '$currentStep'),
              const Divider(),
              _debugRow('email', emailCtrl.text),
              _debugRow('phone', phoneCtrl.text),
              _debugRow('password', passwordCtrl.text),
              const Divider(),
              _debugRow('postNom', postNomCtrl.text),
              _debugRow('prenom', prenomCtrl.text),
              _debugRow('sexe', sexe),
              _debugRow('lieuNaissance', lieuNaissanceCtrl.text),
              const Divider(),
              _debugRow('province', provinceCtrl.text),
              _debugRow('ville', villeCtrl.text),
              _debugRow('commune', communeCtrl.text),
              _debugRow('quartier', quartierCtrl.text),
              _debugRow('avenue', avenueCtrl.text),
              _debugRow('numero', numeroCtrl.text),
              const Divider(),
              _debugRow('groupeScout', groupeScoutCtrl.text),
              _debugRow('affiliation', numeroAffiliationCtrl.text),
              _debugRow('district', districtCtrl.text),
              _debugRow('association', associationCtrl.text),
              _debugRow('branche', branche.name),
              const Divider(),
              _debugRow('engagement', '$engagementAccepte'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    final isEmpty = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isEmpty ? '(VIDE)' : value,
              style: TextStyle(
                fontSize: 12,
                color: isEmpty ? Colors.red : Colors.black,
                fontWeight: isEmpty ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // Construction du PAYLOAD envoye au backend
  // ===========================================================
  Map<String, dynamic> _buildPayload() {
    final dateN = dateNaissance ?? DateTime(2000, 1, 1);
    final dateE = dateEntreeScout ?? DateTime.now();

    final payload = <String, dynamic>{
      'nom': postNomCtrl.text.trim(),
      'postNom': postNomCtrl.text.trim(),
      'prenom': prenomCtrl.text.trim(),
      if (prenom2Ctrl.text.trim().isNotEmpty)
        'prenom2': prenom2Ctrl.text.trim(),
      'sexe': sexe,
      'dateNaissance': dateN.toIso8601String().split('T')[0],
      'lieuNaissance': lieuNaissanceCtrl.text.trim(),
      'email': emailCtrl.text.trim().toLowerCase(),
      'phone': phoneCtrl.text.trim(),
      'password': passwordCtrl.text,
      'province': provinceCtrl.text.trim(),
      'ville': villeCtrl.text.trim(),
      'commune': communeCtrl.text.trim(),
      'quartier': quartierCtrl.text.trim(),
      'avenue': avenueCtrl.text.trim(),
      'numero': numeroCtrl.text.trim(),
      'pays': 'RDC',
      'groupeScout': groupeScoutCtrl.text.trim(),
      if (groupeScoutId != null) 'groupeScoutId': groupeScoutId,
      'numeroAffiliation': numeroAffiliationCtrl.text.trim(),
      'district': districtCtrl.text.trim(),
      'association': associationCtrl.text.trim(),
      'branche': branche.backendValue,
      'dateEntreeScout': dateE.toIso8601String().split('T')[0],
      if (fonctionScoutCtrl.text.trim().isNotEmpty)
        'fonction': fonctionScoutCtrl.text.trim(),
      if (professionCtrl.text.trim().isNotEmpty)
        'profession': professionCtrl.text.trim(),
      if (antecedentsCtrl.text.trim().isNotEmpty)
        'antecedentsMedicaux': antecedentsCtrl.text.trim(),
      'engagementAccepte': engagementAccepte,
    };

    if (camps.isNotEmpty) {
      payload['camps'] = camps.map((c) => c.toJson()).toList();
    }
    if (contactsUrgence.isNotEmpty) {
      payload['contacts'] = contactsUrgence.map((c) => c.toJson()).toList();
    }

    return payload;
  }

  // ===========================================================
  // SOUMISSION
  // ===========================================================
  Future<void> _submit() async {
    // Validation engagement
    if (!engagementAccepte) {
      SnackbarHelper.warning(context, "Veuillez accepter l'engagement");
      return;
    }

    // Validation mot de passe
    if (passwordCtrl.text.length < 6) {
      SnackbarHelper.error(context, 'Mot de passe : minimum 6 caracteres');
      return;
    }

    // Validation email
    if (emailCtrl.text.trim().isEmpty) {
      SnackbarHelper.error(context, 'Email obligatoire');
      return;
    }

    // Validation telephone
    if (phoneCtrl.text.trim().isEmpty) {
      SnackbarHelper.error(context, 'Telephone obligatoire');
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      final payload = _buildPayload();
      debugPrint('PAYLOAD = $payload');

      final service = context.read<RegisterService>();
      final result = await service.registerComplete(payload: payload);

      if (!mounted) return;

      // Verification du succes (plusieurs cles possibles)
      final isSuccess = result['success'] == true ||
          result['ok'] == true ||
          result['status'] == 'success';

      if (isSuccess) {
        final auth = context.read<AuthController>();
        await auth.bootstrap();
        if (!mounted) return;

        SnackbarHelper.success(
          context,
          'Compte cree ! Bienvenue ${prenomCtrl.text}',
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.homeForRole(
            auth.currentUser?.role.name ?? 'apprenant',
          ),
          (route) => false,
        );
      } else {
        final msg = result['message']?.toString() ??
            result['error']?.toString() ??
            'Erreur inconnue';
        setState(() => errorMessage = msg);
        SnackbarHelper.error(context, msg);
      }
    } catch (e, st) {
      debugPrint('Submit error: $e');
      debugPrint('$st');
      if (!mounted) return;
      setState(() => errorMessage = e.toString());
      SnackbarHelper.error(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  // ===========================================================
  // BUILD
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.orange,
        onPressed: _showDebugDialog,
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text('Creer un compte'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        leading: currentStep == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isSubmitting ? null : _prev,
              ),
      ),
      body: Column(
        children: [
          _buildProgress(),
          Expanded(child: _buildCurrentStep()),
          if (errorMessage != null) _buildError(),
          _buildNav(),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return Step1Account(state: this);
      case 1:
        return Step2Identity(state: this);
      case 2:
        return Step3Address(state: this);
      case 3:
        return Step4Scout(state: this);
      case 4:
        return Step5ProHealth(state: this);
      case 5:
        return Step6Engagement(state: this);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProgress() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(6, (i) {
              final active = i <= currentStep;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 5 ? 4 : 0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: active ? AppColors.mauve : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Etape ${currentStep + 1}/6 - ${_titles[currentStep]}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.dangerDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    final isLast = currentStep == 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : _prev,
                  child: const Text('Precedent'),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : (isLast ? _submit : _next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? AppColors.success : AppColors.mauve,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        isLast ? 'Creer mon compte' : 'Suivant',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
