// =============================================================
// ChefUnitPlus - Ecran Badge QR
// Affiche le badge utilisateur avec QR code
// UNIQUEMENT si le compte est active (is_active = 1)
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/role_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user.dart';

class UserBadgeScreen extends StatefulWidget {
  const UserBadgeScreen({super.key});

  @override
  State<UserBadgeScreen> createState() => _UserBadgeScreenState();
}

class _UserBadgeScreenState extends State<UserBadgeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon badge'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: Text('Utilisateur non connecte'))
          : !user.isActive
              ? _buildNotActive(user)
              : _buildBadge(user),
    );
  }

  // COMPTE NON ACTIVE : message d'attente
  Widget _buildNotActive(User user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 60,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Badge en attente d\'activation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Votre compte doit d\'abord etre active par le directeur pedagogique pour recevoir votre badge.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Statut : En attente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COMPTE ACTIVE : badge + QR
  Widget _buildBadge(User user) {
    final qrData = _buildQrData(user);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // CARTE BADGE
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mauve, AppColors.kaki],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mauve.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header : ChefUnitPlus
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.school, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'ChefUnitPlus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.label.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Corps du badge
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            user.role.color.withValues(alpha: 0.15),
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: user.role.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.fullName.isNotEmpty
                            ? user.fullName
                            : 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _infoRow(
                        'ID',
                        user.id.length > 8
                            ? user.id.substring(0, 8).toUpperCase()
                            : user.id.toUpperCase(),
                      ),
                      const SizedBox(height: 6),
                      _infoRow(
                        'Telephone',
                        user.phone.isNotEmpty ? user.phone : '-',
                      ),
                    ],
                  ),
                ),
                // QR Code
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 160,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.mauveDark,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.mauveDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Scannez ce QR pour verifier',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // BOUTON TELECHARGER PDF
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _downloadPdf(user),
              icon: const Icon(Icons.download),
              label: const Text('Telecharger le badge PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mauve,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // INFO COMPTE ACTIF
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Votre compte est actif. Badge valide.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _buildQrData(User user) {
    return 'chefunitplus://user/${user.id}?email=${user.email}&role=${user.role.name}';
  }

  void _downloadPdf(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Telechargement PDF bientot disponible'),
        backgroundColor: AppColors.kaki,
      ),
    );
  }
}