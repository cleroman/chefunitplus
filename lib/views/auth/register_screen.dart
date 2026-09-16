// =============================================================
// ChefUnitPlus - RegisterScreen
// Inscription avec : nom complet, email, téléphone, mot de passe
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ===========================================================
  // 📤 SOUMISSION
  // ===========================================================
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      SnackbarHelper.warning(
        context,
        'Veuillez accepter les conditions d\'utilisation',
      );
      return;
    }

    final auth = context.read<AuthController>();

    // ✅ APPEL CORRIGÉ — tous les paramètres nommés requis fournis
    final success = await auth.register(
      fullName: _nameCtrl.text.trim(),   // ✅ requis
      email: _emailCtrl.text.trim(),      // ✅ requis
      phone: _phoneCtrl.text.trim(),      // ✅ requis
      password: _passwordCtrl.text,       // ✅ requis
    );

    if (!mounted) return;

    if (success) {
      SnackbarHelper.success(context, AppStrings.registerSuccess);
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.homeForRole(auth.currentUser!.role.name),
      );
    } else {
      SnackbarHelper.error(
        context,
        auth.errorMessage ?? AppStrings.errorUnknown,
      );
    }
  }

  // ===========================================================
  // 🎨 UI
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.register),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.mauveDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bandeau info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mauveSoft,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.mauve,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vous serez inscrit en tant qu\'apprenant. '
                          'Un directeur ou administrateur pourra vous '
                          'promouvoir plus tard.',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                AppColors.mauveDark.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Nom complet
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.fullName,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // Téléphone
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.phone,
                    hintText: '24389XXXXXXX',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.mobileMoneyPhone,
                ),
                const SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),

                // Confirmation
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _passwordCtrl.text,
                  ),
                ),
                const SizedBox(height: 12),

                // Conditions
                CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (v) =>
                      setState(() => _acceptTerms = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'J\'accepte les conditions d\'utilisation '
                    'et la politique de confidentialité',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton
                SizedBox(
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mauve,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            AppStrings.registerButton,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Lien connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.hasAccount,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
