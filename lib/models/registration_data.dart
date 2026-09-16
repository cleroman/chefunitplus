// =============================================================
// ChefUnitPlus - Modele RegistrationData
// Contient toutes les donnees du formulaire d'inscription
// =============================================================

import 'scout_camp.dart';
import 'emergency_contact.dart';

class RegistrationData {
  // --- Identite ---
  String nom = '';
  String postNom = '';
  String prenom = '';
  String sexe = 'homme';
  String dateNaissance = '';
  String lieuNaissance = '';
  String? photoPath;

  // --- Contact ---
  String telephone = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  // --- Adresse ---
  String province = '';
  String ville = '';
  String commune = '';
  String quartier = '';
  String avenue = '';
  String numero = '';

  // --- Scout ---
  String groupeScout = '';
  String numeroAffiliation = '';
  String district = '';
  String association = '';
  String branche = 'meute';
  String dateEntreeScout = '';
  String fonction = '';
  String profession = '';
  String niveauEtude = '';
  String antecedentsMedicaux = '';
  String? attestationCampUrl;

  // --- Camps ---
  List<ScoutCamp> camps = [];

  // --- Contacts d'urgence ---
  List<EmergencyContact> emergencyContacts = [];

  // --- Engagement ---
  bool engagementAccepte = false;

  RegistrationData();

  Map<String, dynamic> toJson() => {
        // Identite
        'nom': nom,
        'postNom': postNom,
        'prenom': prenom,
        'sexe': sexe,
        'dateNaissance': dateNaissance,
        'lieuNaissance': lieuNaissance,
        // Contact
        'phone': telephone,
        'email': email,
        'password': password,
        // Adresse
        'province': province,
        'ville': ville,
        'commune': commune,
        'quartier': quartier,
        'avenue': avenue,
        'numero': numero,
        // Scout
        'groupeScout': groupeScout,
        'numeroAffiliation': numeroAffiliation,
        'district': district,
        'association': association,
        'branche': branche,
        'dateEntreeScout': dateEntreeScout,
        'fonction': fonction,
        'profession': profession,
        'niveauEtude': niveauEtude,
        'antecedentsMedicaux': antecedentsMedicaux,
        'attestationCampUrl': attestationCampUrl,
        // Listes
        'camps': camps.map((c) => c.toJson()).toList(),
        'emergencyContacts':
            emergencyContacts.map((c) => c.toJson()).toList(),
        // Engagement
        'engagementAccepte': engagementAccepte,
      };
}
