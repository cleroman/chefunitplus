// =============================================================
// ChefUnitPlus - PaymentScreen (redirection)
// Ce fichier redirige vers LearnerPaymentScreen
// (conserve pour compatibilite avec les anciens imports)
// =============================================================

import 'package:flutter/material.dart';
import '../learner/learner_payment_screen.dart';

class PaymentScreen extends StatelessWidget {
  final double amount;
  final String formationTitle;
  final String? formationId;
  final String? enrollmentId;

  const PaymentScreen({
    super.key,
    this.amount = 0,
    this.formationTitle = '',
    this.formationId,
    this.enrollmentId,
  });

  @override
  Widget build(BuildContext context) {
    return LearnerPaymentScreen(
      amount: amount,
      formationTitle: formationTitle,
      formationId: formationId,
      enrollmentId: enrollmentId,
    );
  }
}