// =============================================================
// ChefUnitPlus - RoleRouter
// Redirige vers le dashboard adapte au role
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/role_constants.dart';
import '../admin/admin_dashboard.dart';
import '../director/director_dashboard.dart';
import '../learner/learner_dashboard.dart';
import '../trainer/trainer_dashboard.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    if (user == null) {
      return const _Denied(message: 'Vous devez etre connecte.');
    }

    if (!user.isActive) {
      return const _Denied(message: 'Votre compte est suspendu.');
    }

    switch (user.role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.directeur:
        return const DirectorDashboard();
      case UserRole.formateur:
        return const TrainerDashboard();
      case UserRole.apprenant:
        return const LearnerDashboard();
    }
  }
}

class _Denied extends StatelessWidget {
  final String message;
  const _Denied({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: AppColors.danger),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.read<AuthController>().logout(),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Se deconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}