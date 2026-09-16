import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';


Future<String?> showValidationCommentDialog({
  required BuildContext context,
  required bool approve,
}) async {
  final ctrl = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        approve ? 'Valider l\'inscription' : 'Refuser l\'inscription',
      ),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: approve ? 'Commentaire (optionnel)' : 'Raison du refus',
          hintText: approve
              ? 'Bienvenue dans la formation...'
              : 'Paiement non conforme...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: approve ? AppColors.success : AppColors.danger,
          ),
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: Text(approve ? 'Valider' : 'Refuser'),
        ),
      ],
    ),
  );

  ctrl.dispose();
  return result;
}