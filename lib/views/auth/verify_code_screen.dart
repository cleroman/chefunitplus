// =============================================================
// ChefUnitPlus - Ecran de verification du code d'inscription
// Version complete : Timer 24h + Retry + Back ameliore
// =============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/snackbar_helper.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _resending = false;
  bool _retrying = false;
  String? _error;

  // Timer pour le compte a rebours (24h)
  Timer? _timer;
  Duration _timeLeft = const Duration(hours: 24);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  // ===========================================================
  // TIMER 24H
  // ===========================================================
  void _startTimer() {
    _timer?.cancel();
    _timeLeft = const Duration(hours: 24);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          _timeLeft = Duration.zero;
        });
      } else {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return 'Expire';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ===========================================================
  // SOUMISSION DU CODE
  // ===========================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthController>();
      final result = await auth.verifyCode(
        email: widget.email,
        code: _codeCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await auth.bootstrap();
        if (!mounted) return;

        final stage = auth.registrationStage;


        // FIX REDIRECTION FORCEE
        // Si le code est utilise mais preuves pas encore soumises,
        // on force la redirection vers submit-proofs
        final currentUser = auth.currentUser;
        final needsProofs = (currentUser != null) &&
            (currentUser.codeIsUsed == true) &&
            (currentUser.proofsSubmittedAt == null);

        if (needsProofs) {
          SnackbarHelper.success(
            context,
            'Code verifie ! Soumettez vos preuves de formation.',
          );
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.submitProofs,
            arguments: {'email': widget.email},
          );
          return;
        }

        switch (stage) {
          case 'active':
            SnackbarHelper.success(context, 'Compte active !');
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.homeForRole(auth.currentUser!.role.name),
            );
            break;

          case 'proofs_pending':
            SnackbarHelper.success(
              context,
              'Code verifie ! Soumettez vos preuves.',
            );
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.submitProofs,
              arguments: {'email': widget.email},
            );
            break;

          case 'awaiting_validation':
          default:
            SnackbarHelper.success(
              context,
              'Code verifie ! En attente de validation.',
            );
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.pendingValidation,
              arguments: {'email': widget.email},
            );
            break;
        }
      } else {
        setState(() {
          _error = result['message'] ?? 'Code invalide';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur : ${e.toString()}';
        _loading = false;
      });
    }
  }

  // ===========================================================
  // REESSAYER (sablier anime)
  // ===========================================================
  Future<void> _retry() async {
    if (_codeCtrl.text.trim().isEmpty) {
      setState(() {
        _error = 'Entrez d\'abord le code a 6 chiffres';
      });
      return;
    }

    setState(() {
      _retrying = true;
      _error = null;
    });

    // Sablier : attendre 3 secondes
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() => _retrying = false);

    // Reessayer la soumission
    await _submit();
  }

  // ===========================================================
  // RENVOYER LE CODE
  // ===========================================================
  Future<void> _resendCode() async {
    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthController>();
      final result = await auth.resendCode(email: widget.email);

      if (!mounted) return;

      if (result['success'] == true) {
        SnackbarHelper.success(
          context,
          'Nouveau code envoye a ${widget.email}',
        );
        _startTimer();
      } else {
        SnackbarHelper.error(
          context,
          result['message'] ?? 'Impossible de renvoyer le code',
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.error(context, 'Erreur : $e');
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  // ===========================================================
  // DIALOGUE RETOUR
  // ===========================================================
  Future<void> _showBackDialog() async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Que voulez-vous faire ?'),
        content: const Text(
          'Voulez-vous generer un nouveau code ou retourner a l\'authentification ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'generate'),
            child: const Text('Generer un nouveau code'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mauve,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retour a l\'authentification'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    switch (action) {
      case 'generate':
        await _resendCode();
        break;
      case 'back':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
        break;
      default:
        break;
    }
  }

  // ===========================================================
  // BUILD
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    final timerExpired = _timeLeft.inSeconds <= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: _showBackDialog,
        ),
        title: const Text('Verification du code'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.sms_outlined,
                  size: 72,
                  color: AppColors.mauve,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Saisissez votre code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Un code a 6 chiffres a ete envoye a :\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),

                // ============================================================
                // WIDGET TIMER 24H
                // ============================================================
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: timerExpired
                        ? AppColors.danger.withValues(alpha: 0.1)
                        : AppColors.mauve.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: timerExpired
                          ? AppColors.danger.withValues(alpha: 0.3)
                          : AppColors.mauve.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        timerExpired ? Icons.timer_off : Icons.timer_outlined,
                        color: timerExpired ? AppColors.danger : AppColors.mauve,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timerExpired
                            ? 'Code expire - Generez un nouveau code'
                            : 'Expire dans : ${_formatDuration(_timeLeft)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: timerExpired
                              ? AppColors.danger
                              : AppColors.mauve,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  enabled: !timerExpired,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Entrez le code';
                    }
                    if (v.length != 6) {
                      return 'Le code doit contenir 6 chiffres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // ============================================================
                // BOUTON VALIDER
                // ============================================================
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_loading || timerExpired) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mauve,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Valider le code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // ============================================================
                // BOUTON REESSAYER (avec sablier)
                // ============================================================
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: (_retrying || _loading || timerExpired)
                        ? null
                        : _retry,
                    icon: _retrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mauve,
                            ),
                          )
                        : const Icon(Icons.refresh, size: 20),
                    label: Text(
                      _retrying ? 'Nouvel essai...' : 'Reessayer le code',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mauve,
                      side: const BorderSide(color: AppColors.mauve),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ============================================================
                // BOUTON RENVOYER
                // ============================================================
                TextButton.icon(
                  onPressed: (_loading || _resending) ? null : _resendCode,
                  icon: _resending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined, size: 18),
                  label: Text(
                    _resending ? 'Envoi en cours...' : 'Renvoyer le code',
                  ),
                ),

                const SizedBox(height: 8),

                // ============================================================
                // BOUTON RETOUR A L'AUTHENTIFICATION
                // ============================================================
                TextButton(
                  onPressed: _showBackDialog,
                  child: const Text(
                    'Retour a l\'authentification',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
