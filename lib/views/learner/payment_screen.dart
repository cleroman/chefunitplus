import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/formation.dart';
import 'otp_input_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Formation formation;
  const PaymentScreen({super.key, required this.formation});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);

    final ctrl = context.read<EnrollmentController>();
    final enrollment = await ctrl.request(
      widget.formation.id,
      phone: _phoneCtrl.text.trim(),
      accountName: _accountCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _processing = false);

    if (enrollment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.errorMessage ?? 'Echec de la demande'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Naviguer vers l'ecran OTP
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpInputScreen(
          enrollmentId: enrollment.id,
          formationTitle: widget.formation.title,
          amount: widget.formation.priceLabel,
          phone: _phoneCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.formation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Recapitulatif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Formation',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      f.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant'),
                        Text(
                          f.priceLabel,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mauve,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kaki.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.kaki, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vous recevrez un code OTP par SMS. Saisissez-le pour valider le paiement.',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Telephone
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numero Mobile Money',
                  hintText: 'Ex: 243890000000',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(),
                  helperText: 'Format international sans espaces',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  final c = v.replaceAll(RegExp(r'\D'), '');
                  if (c.length < 9) return 'Numero trop court';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nom du compte
              TextFormField(
                controller: _accountCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom du compte de transfert',
                  hintText: 'Ex: MAJILA MUZAILA Grace',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  helperText: 'Nom exact tel qu\'il apparait sur votre compte',
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Au moins 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _processing ? null : _submit,
                  icon: _processing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.payment),
                  label: Text(
                    _processing
                        ? 'Traitement...'
                        : 'Payer ${f.priceLabel}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mauve,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}