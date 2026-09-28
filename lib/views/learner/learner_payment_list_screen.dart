// =============================================================
// ChefUnitPlus - LearnerPaymentListScreen
// Permet a l'apprenant de choisir une formation pour payer
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/formation_controller.dart';
import '../../core/constants/app_colors.dart';
import 'learner_payment_screen.dart';

class LearnerPaymentListScreen extends StatefulWidget {
  const LearnerPaymentListScreen({super.key});

  @override
  State<LearnerPaymentListScreen> createState() =>
      _LearnerPaymentListScreenState();
}

class _LearnerPaymentListScreenState extends State<LearnerPaymentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FormationController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choisir une formation'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FormationController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final formations = ctrl.formations;
          if (formations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, size: 80, color: AppColors.textMuted),
                    SizedBox(height: 16),
                    Text(
                      'Aucune formation disponible',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Les formations publiees apparaitront ici.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: formations.length,
            itemBuilder: (_, i) {
              final f = formations[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.mauve.withValues(alpha: 0.15),
                    child: const Icon(Icons.school, color: AppColors.mauve),
                  ),
                  title: Text(
                    f.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${f.price} USD',
                    style: const TextStyle(color: AppColors.mauve),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LearnerPaymentScreen(
                          amount: f.price,
                          formationTitle: f.title,
                          formationId: f.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}