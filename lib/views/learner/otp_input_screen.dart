import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/enrollment_controller.dart';

class OtpInputScreen extends StatefulWidget {
  final String enrollmentId;
  final String formationTitle;
  final String amount;
  final String phone;

  const OtpInputScreen({
    super.key,
    required this.enrollmentId,
    required this.formationTitle,
    required this.amount,
    required this.phone,
  });

  @override
  State<OtpInputScreen> createState() => _OtpInputScreenState();
}

class _OtpInputScreenState extends State<OtpInputScreen> {
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _processing = false;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _startCountdown();
      }
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);

    final ctrl = context.read<EnrollmentController>();
    final ok = await ctrl.confirmOtp(widget.enrollmentId, _otpCtrl.text.trim());

    if (!mounted) return;
    setState(() => _processing = false);

    if (ok) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text('Paiement confirme'),
            ],
          ),
          content: const Text(
            'Votre paiement a ete enregistre.\n\n'
            'Votre inscription est maintenant en attente de validation par le directeur.\n\n'
            'Vous serez notifie une fois validee.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mauve,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.errorMessage ?? 'Code OTP invalide'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification OTP'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Icone
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.mauve.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  size: 60,
                  color: AppColors.mauve,
                ),
              ),
              const SizedBox(height: 32),

              // Titre
              const Text(
                'Entrez le code OTP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Un code a 6 chiffres a ete envoye au\n${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Champ OTP
              TextFormField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12,
                  color: AppColors.mauveDark,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(
                    fontSize: 32,
                    letterSpacing: 12,
                    color: AppColors.divider,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
                validator: (v) {
                  if (v == null || v.length < 4) return 'Code invalide';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton confirmer
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _processing ? null : _confirm,
                  icon: _processing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_processing ? 'Verification...' : 'Confirmer le paiement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
              const SizedBox(height: 20),

              // Renvoyer
              TextButton.icon(
                onPressed: _resendCountdown > 0
                    ? null
                    : () {
                        setState(() => _resendCountdown = 60);
                        _startCountdown();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nouveau code OTP envoye'),
                            backgroundColor: AppColors.mauve,
                          ),
                        );
                      },
                icon: const Icon(Icons.refresh),
                label: Text(
                  _resendCountdown > 0
                      ? 'Renvoyer dans $_resendCountdown s'
                      : 'Renvoyer le code',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}