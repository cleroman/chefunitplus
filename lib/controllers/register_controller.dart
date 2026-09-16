// =============================================================
// ChefUnitPlus - RegisterController
// FIX ULTIME : TextEditingControllers stockes ICI (source de verite)
// =============================================================

import 'package:flutter/material.dart';

import 'package:chefunitplus/models/user_details.dart';
import 'package:chefunitplus/models/scout_camp.dart';
import 'package:chefunitplus/models/emergency_contact.dart';

class RegisterController extends ChangeNotifier {
  int _currentStep = 0;
  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < 5) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // ===========================================================
  // ETAPE 1 - COMPTE
  // ===========================================================
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // ===========================================================
  // ETAPE 2 - IDENTITE
  // ===========================================================
  final postNomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final prenom2Ctrl = TextEditingController();
  final lieuNaissanceCtrl = TextEditingController();
  String sexe = 'homme';
  DateTime? dateNaissance;

  // ===========================================================
  // ETAPE 3 - ADRESSE
  // ===========================================================
  final provinceCtrl = TextEditingController();
  final villeCtrl = TextEditingController();
  final communeCtrl = TextEditingController();
  final quartierCtrl = TextEditingController();
  final avenueCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();

  // ===========================================================
  // ETAPE 4 - SCOUT
  // ===========================================================
  final groupeScoutCtrl = TextEditingController();
  final numeroAffiliationCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final associationCtrl = TextEditingController();
  final fonctionScoutCtrl = TextEditingController();
  ScoutBranch branche = ScoutBranch.eclaireurs;
  DateTime? dateEntreeScout;

  // ===========================================================
  // ETAPE 5 - PRO / SANTE
  // ===========================================================
  final professionCtrl = TextEditingController();
  final antecedentsCtrl = TextEditingController();
  String? attestationCampUrl;
  final List<ScoutCamp> camps = [];
  final List<EmergencyContact> contactsUrgence = [];

  void addCamp(ScoutCamp camp) {
    camps.add(camp);
    notifyListeners();
  }

  void removeCamp(int index) {
    if (index >= 0 && index < camps.length) {
      camps.removeAt(index);
      notifyListeners();
    }
  }

  void addContact(EmergencyContact contact) {
    contactsUrgence.add(contact);
    notifyListeners();
  }

  void removeContact(int index) {
    if (index >= 0 && index < contactsUrgence.length) {
      contactsUrgence.removeAt(index);
      notifyListeners();
    }
  }

  // ===========================================================
  // ETAPE 6 - ENGAGEMENT
  // ===========================================================
  bool engagementAccepte = false;
  DateTime? engagementDate;

  void acceptEngagement(bool value) {
    engagementAccepte = value;
    if (value && engagementDate == null) {
      engagementDate = DateTime.now();
    }
    notifyListeners();
  }

  // ===========================================================
  // ETAT
  // ===========================================================
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ===========================================================
  // PAYLOAD - Lecture directe depuis les controllers
  // ===========================================================
  Map<String, dynamic> buildFullPayload() {
    final dateN = dateNaissance ?? DateTime(2000, 1, 1);
    final dateE = dateEntreeScout ?? DateTime.now();

    final payload = <String, dynamic>{
      // ----- IDENTITE -----
      'nom': postNomCtrl.text.trim(),
      'postNom': postNomCtrl.text.trim(),
      'prenom': prenomCtrl.text.trim(),
      if (prenom2Ctrl.text.trim().isNotEmpty)
        'prenom2': prenom2Ctrl.text.trim(),
      'sexe': sexe,
      'dateNaissance': dateN.toIso8601String().split('T')[0],
      'lieuNaissance': lieuNaissanceCtrl.text.trim(),

      // ----- CONTACT -----
      'email': emailCtrl.text.trim().toLowerCase(),
      'phone': phoneCtrl.text.trim(),
      'password': passwordCtrl.text,

      // ----- ADRESSE -----
      'province': provinceCtrl.text.trim(),
      'ville': villeCtrl.text.trim(),
      'commune': communeCtrl.text.trim(),
      'quartier': quartierCtrl.text.trim(),
      'avenue': avenueCtrl.text.trim(),
      'numero': numeroCtrl.text.trim(),
      'pays': 'RDC',

      // ----- SCOUT -----
      'groupeScout': groupeScoutCtrl.text.trim(),
      'numeroAffiliation': numeroAffiliationCtrl.text.trim(),
      'district': districtCtrl.text.trim(),
      'association': associationCtrl.text.trim(),
      'branche': branche.backendValue,
      'dateEntreeScout': dateE.toIso8601String().split('T')[0],
      if (fonctionScoutCtrl.text.trim().isNotEmpty)
        'fonction': fonctionScoutCtrl.text.trim(),

      // ----- PRO / SANTE -----
      if (professionCtrl.text.trim().isNotEmpty)
        'profession': professionCtrl.text.trim(),
      if (antecedentsCtrl.text.trim().isNotEmpty)
        'antecedentsMedicaux': antecedentsCtrl.text.trim(),
      if (attestationCampUrl != null)
        'attestationCampUrl': attestationCampUrl,

      // ----- ENGAGEMENT -----
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
  // SETTERS PUBLICS (avec notifyListeners integre)
  // ===========================================================
  void setSexe(String value) {
    sexe = value;
    notifyListeners();
  }

  void setBranche(ScoutBranch value) {
    branche = value;
    notifyListeners();
  }

  void setDateNaissance(DateTime value) {
    dateNaissance = value;
    notifyListeners();
  }

  void setDateEntreeScout(DateTime value) {
    dateEntreeScout = value;
    notifyListeners();
  }

  void setEngagementAccepte(bool value) {
    engagementAccepte = value;
    if (value && engagementDate == null) {
      engagementDate = DateTime.now();
    }
    notifyListeners();
  }

  void setAttestationCampUrl(String? value) {
    attestationCampUrl = value;
    notifyListeners();
  }

  // ===========================================================
  // RESET
  // ===========================================================
  void reset() {
    _currentStep = 0;
    emailCtrl.clear();
    phoneCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    postNomCtrl.clear();
    prenomCtrl.clear();
    prenom2Ctrl.clear();
    lieuNaissanceCtrl.clear();
    sexe = 'homme';
    dateNaissance = null;
    provinceCtrl.clear();
    villeCtrl.clear();
    communeCtrl.clear();
    quartierCtrl.clear();
    avenueCtrl.clear();
    numeroCtrl.clear();
    groupeScoutCtrl.clear();
    numeroAffiliationCtrl.clear();
    districtCtrl.clear();
    associationCtrl.clear();
    fonctionScoutCtrl.clear();
    branche = ScoutBranch.eclaireurs;
    dateEntreeScout = null;
    professionCtrl.clear();
    antecedentsCtrl.clear();
    attestationCampUrl = null;
    camps.clear();
    contactsUrgence.clear();
    engagementAccepte = false;
    engagementDate = null;
    _isSubmitting = false;
    _errorMessage = null;
    notifyListeners();
  }

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
    associationCtrl.dispose();
    fonctionScoutCtrl.dispose();
    professionCtrl.dispose();
    antecedentsCtrl.dispose();
    super.dispose();
  }
}