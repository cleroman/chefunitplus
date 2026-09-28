// =============================================================
// ChefUnitPlus - LearnerPaymentScreen
// Paiement Mobile Money par l'apprenant
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/payment_numbers_service.dart';
import '../../../services/payment_request_service.dart';

class LearnerPaymentScreen extends StatefulWidget {
  final double amount;
  final String? formationId;
  final String? enrollmentId;
  final String formationTitle;

  const LearnerPaymentScreen({
    super.key,
    required this.amount,
    required this.formationTitle,
    this.formationId,
    this.enrollmentId,
  });

  @override
  State<LearnerPaymentScreen> createState() => _LearnerPaymentScreenState();
}

class _LearnerPaymentScreenState extends State<LearnerPaymentScreen> {
  List<Map<String, dynamic>> _numbers = [];
  bool _loading = true;
  String? _error;

  String? _selectedOperator;
  Map<String, dynamic>? _selectedNumber;
  final _referenceCtrl = TextEditingController();
  final _senderNameCtrl = TextEditingController();
  final _senderPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _referenceCtrl.dispose();
    _senderNameCtrl.dispose();
    _senderPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<PaymentNumbersService>();
      final numbers = await service.listActive();
      if (mounted) {
        setState(() {
          _numbers = numbers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<String> get _operators {
    final set = <String>{};
    for (final n in _numbers) {
      set.add(n['operator'] as String);
    }
    return set.toList();
  }

  String _operatorLabel(String op) {
    switch (op) {
      case 'airtel':   return 'Airtel Money';
      case 'vodacom':  return 'Vodacom M-Pesa';
      case 'orange':   return 'Orange Money';
      case 'africell': return 'Africell Money';
      default:         return op;
    }
  }

  String _formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }

  Color _operatorColor(String op) {
    switch (op) {
      case 'airtel':   return const Color(0xFFE30613);
      case 'vodacom':  return const Color(0xFFE60000);
      case 'orange':   return const Color(0xFFFF7900);
      case 'africell': return const Color(0xFF0072CE);
      default:         return AppColors.mauve;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Reessayer')),
            ],
          ),
        ),
      );
    }

    if (_numbers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: AppColors.textMuted),
              SizedBox(height: 16),
              Text(
                'Aucun numero de paiement disponible',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              SizedBox(height: 8),
              Text(
                'Contactez l\'administrateur',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        if (_selectedOperator == null) _buildOperatorChoice(),
        if (_selectedOperator != null && _selectedNumber == null) _buildAccountChoice(),
        if (_selectedNumber != null) _buildReferenceInput(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
            widget.formationTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Montant : ',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              Text(
                '${widget.amount.toStringAsFixed(2)} USD',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etape 1 : Choisissez votre reseau',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._operators.map((op) {
          final count = _numbers.where((n) => n['operator'] == op).length;
          return _operatorCard(op, count);
        }),
      ],
    );
  }

  Widget _operatorCard(String op, int count) {
    final color = _operatorColor(op);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selectedOperator = op),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      op[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _operatorLabel(op),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count compte(s) disponible(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountChoice() {
    final filtered = _numbers.where((n) => n['operator'] == _selectedOperator).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() {
            _selectedOperator = null;
            _selectedNumber = null;
          }),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Retour'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Etape 2 : Envoyez le montant a :',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.map((n) => _accountCard(n)),
      ],
    );
  }

  Widget _accountCard(Map<String, dynamic> n) {
    final color = _operatorColor(n['operator'] as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selectedNumber = n),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n['display_name'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      _formatPhone(n['phone_number'] as String? ?? ''),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mauve,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _operatorLabel(n['operator'] as String),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _selectedNumber = null),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Retour'),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Effectuez le paiement :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _recapRow('Nom', _selectedNumber!['display_name'] as String? ?? ''),
              _recapRow('Numero', _formatPhone(_selectedNumber!['phone_number'] as String? ?? '')),
              _recapRow('Montant', '${widget.amount.toStringAsFixed(2)} USD'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Etape 3 : Saisissez le code de reference',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Entrez les 6 derniers chiffres du message recu',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        const Text(
          'Exemple : 123456',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mauve,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Nom du compte
        TextField(
          controller: _senderNameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nom du compte',
            hintText: 'Ex: Jean Dupont',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),

        // Numero de telephone
        TextField(
          controller: _senderPhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Numero utilise pour la transaction',
            hintText: 'Ex: 099 123 4567',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 12),

        // Code de reference
        TextField(
          controller: _referenceCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Code de reference (6 chiffres)',
            hintText: 'Ex: 123456',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.confirmation_number),
            counterText: '',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Le code de reference vous a ete envoye par SMS apres le paiement.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Confirmer le paiement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mauve,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final ref = _referenceCtrl.text.trim();
    final senderName = _senderNameCtrl.text.trim();
    final senderPhone = _senderPhoneCtrl.text.trim();

    // Validation
    if (senderName.length < 2) {
      _showSnack('Saisissez le nom du compte', isError: true);
      return;
    }
    if (senderPhone.replaceAll(RegExp(r'\s'), '').length < 9) {
      _showSnack('Saisissez un numero de telephone valide', isError: true);
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(ref)) {
      _showSnack('Le code doit contenir 6 chiffres. Exemple : 123456', isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer le paiement ?'),
        content: Text(
          'Montant : ${widget.amount.toStringAsFixed(2)} USD\n'
          'A : ${_selectedNumber!['display_name']}\n'
          'Reference : $ref\n\n'
          'Votre paiement sera soumis a validation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    // Capturer AVANT le await
    final service = context.read<PaymentRequestService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await service.create(
        paymentNumberId: _selectedNumber!['id'] as String,
        amount: widget.amount,
        referenceNumber: ref,
        senderName: senderName,
        senderPhone: senderPhone,
        formationId: widget.formationId,
        enrollmentId: widget.enrollmentId,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
          title: const Text('Paiement soumis'),
          content: const Text(
            'Votre paiement a ete soumis.\n'
            'Il sera valide par le directeur sous peu.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                navigator.pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }
}