import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/register_controller.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeCtrl = TextEditingController();
  int _resendCooldown = 0;

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez les 6 chiffres'), backgroundColor: AppColors.warning));
      return;
    }
    final ctrl = context.read<RegisterController>();
    final ok = await ctrl.verifyEmail(code);
    if (!mounted) return;
    if (ok) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 8), Text('Compte verifie')]),
        content: const Text('Votre compte est active.'),
        actions: [ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve),
          child: const Text('Se connecter'))],
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ctrl.errorMessage ?? 'Code invalide'), backgroundColor: AppColors.danger));
    }
  }

  Future<void> _resend() async {
    final ctrl = context.read<RegisterController>();
    final ok = await ctrl.resendCode();
    if (!mounted) return;
    if (ok) {
      setState(() => _resendCooldown = 60);
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nouveau code envoye'), backgroundColor: AppColors.success));
    }
  }

  void _startCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _resendCooldown--);
      if (_resendCooldown > 0) _startCooldown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RegisterController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verification email'),
        backgroundColor: AppColors.mauve, foregroundColor: Colors.white),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.mauve.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_unread_outlined, size: 60, color: AppColors.mauve)),
        const SizedBox(height: 24),
        const Text('Verifiez votre email', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text('Un code a 6 chiffres a ete envoye a\n${widget.email}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
        const SizedBox(height: 32),
        TextFormField(controller: _codeCtrl, keyboardType: TextInputType.number, maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, letterSpacing: 12, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(border: OutlineInputBorder(), counterText: '', hintText: '000000')),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: ctrl.isLoading ? null : _verify,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve, foregroundColor: Colors.white),
          child: ctrl.isLoading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Verifier'))),
        const SizedBox(height: 16),
        TextButton(onPressed: _resendCooldown > 0 ? null : _resend,
          child: Text(_resendCooldown > 0 ? 'Renvoyer dans $_resendCooldown s' : 'Renvoyer le code')),
      ])),
    );
  }
}