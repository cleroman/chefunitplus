// =============================================================
// ChefUnitPlus - Registration Success Screen
// Badge de verification avec photo + QR code + infos
// =============================================================
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import 'login_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String? email;
  final String? fullName;
  final Uint8List? photoBytes;
  final String? nom;
  final String? postNom;
  final String? prenom;
  final String? sexe;
  final String? dateNaissance;
  final String? lieuNaissance;
  final String? phone;
  final String? scoutGroupName;
  final String? scoutFunction;
  final String? numeroAffiliation;
  final String? branche;
  final String? province;
  final String? ville;
  final String? commune;

  const RegistrationSuccessScreen({
    super.key,
    this.email,
    this.fullName,
    this.photoBytes,
    this.nom,
    this.postNom,
    this.prenom,
    this.sexe,
    this.dateNaissance,
    this.lieuNaissance,
    this.phone,
    this.scoutGroupName,
    this.scoutFunction,
    this.numeroAffiliation,
    this.branche,
    this.province,
    this.ville,
    this.commune,
  });

  @override
  Widget build(BuildContext context) {
    // Construire le contenu du QR code
    final qrData = 'ChefUnitPlus|'
        'Email:${email ?? ""}|'
        'Nom:${nom ?? ""} ${postNom ?? ""} ${prenom ?? ""}|'
        'Groupe:${scoutGroupName ?? ""}|'
        'Fonction:${scoutFunction ?? ""}|'
        'Affiliation:${numeroAffiliation ?? ""}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inscription reussie'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ============================================================
              // MESSAGE DE SUCCES
              // ============================================================
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Inscription reussie !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mauveDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre compte est en attente de validation (24h)',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ============================================================
              // BADGE DE VERIFICATION
              // ============================================================
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.mauve, AppColors.mauveDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mauve.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // En-tete du badge
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'BADGE DE VERIFICATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Corps du badge (fond blanc)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo de profil
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.mauve, width: 3),
                                ),
                                child: ClipOval(
                                  child: photoBytes != null
                                      ? Image.memory(photoBytes!, fit: BoxFit.cover)
                                      : const Icon(Icons.person, size: 50, color: AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Informations
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${nom ?? ""} ${postNom ?? ""}'.trim(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.mauveDark,
                                      ),
                                    ),
                                    Text(
                                      prenom ?? "",
                                      style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 6),
                                    _infoLine(Icons.email, email ?? ""),
                                    if (phone != null) _infoLine(Icons.phone, phone!),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),

                          // QR Code
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 120,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Scannez pour verifier',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Infos scout
                          if (scoutGroupName != null) _badgeRow('Groupe', scoutGroupName!),
                          if (scoutFunction != null) _badgeRow('Fonction', scoutFunction!),
                          if (numeroAffiliation != null) _badgeRow('Affiliation', numeroAffiliation!),
                          if (branche != null) _badgeRow('Branche', branche!),
                          if (province != null) _badgeRow('Province', province!),
                          if (ville != null) _badgeRow('Ville', ville!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // BOUTON RETOUR
              // ============================================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Retour a la connexion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mauve,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.mauve),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label :',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mauveDark),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}