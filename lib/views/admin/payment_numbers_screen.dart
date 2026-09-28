// =============================================================
// ChefUnitPlus - PaymentNumbersScreen (Admin)
// Gere les numeros de reception Mobile Money
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../services/payment_numbers_service.dart';

class PaymentNumbersScreen extends StatefulWidget {
  const PaymentNumbersScreen({super.key});

  @override
  State<PaymentNumbersScreen> createState() => _PaymentNumbersScreenState();
}

class _PaymentNumbersScreenState extends State<PaymentNumbersScreen> {
  List<Map<String, dynamic>> _numbers = [];
  List<Map<String, dynamic>> _operators = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<PaymentNumbersService>();
      final results = await Future.wait([
        service.list(),
        service.getOperators(),
      ]);

      if (mounted) {
        setState(() {
          _numbers = results[0];
          _operators = results[1];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Numeros Mobile Money'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
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
              Text(
                'Erreur : $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                child: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_numbers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'Aucun numero enregistre',
              style: TextStyle(color: AppColors.textMuted),
            ),
            SizedBox(height: 8),
            Text(
              'Cliquez sur + pour ajouter',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _numbers.length,
        itemBuilder: (_, i) => _buildNumberCard(_numbers[i]),
      ),
    );
  }

  Widget _buildNumberCard(Map<String, dynamic> number) {
    final operator = number['operator'] ?? '';
    final displayName = number['display_name'] ?? '';
    final phoneNumber = number['phone_number'] ?? '';
    final isActive = (number['is_active'] ?? 1) == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icone operateur
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _operatorColor(operator).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _operatorInitial(operator),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _operatorColor(operator),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Inactif',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPhone(phoneNumber),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reference : ${_referenceFormat(operator)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: _operatorColor(operator),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
              onSelected: (action) => _handleAction(action, number),
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: isActive ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.toggle_off : Icons.toggle_on,
                        size: 18,
                        color: isActive ? AppColors.warning : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(isActive ? 'Desactiver' : 'Activer'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _operatorInitial(String op) {
    switch (op) {
      case 'airtel':   return 'A';
      case 'vodacom':  return 'V';
      case 'orange':   return 'O';
      case 'africell': return 'F';
      default:         return '?';
    }
  }

  String _formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }

  String _referenceFormat(String op) {
    switch (op) {
      case 'airtel':   return 'MP + 8 chiffres';
      case 'vodacom':  return 'MP + 8 chiffres';
      case 'orange':   return 'OM + 8 chiffres';
      case 'africell': return 'AF + 8 chiffres';
      default:         return 'XXX XXX XXXX';
    }
  }

  Future<void> _handleAction(String action, Map<String, dynamic> number) async {
    final id = number['id'] as String;
    final service = context.read<PaymentNumbersService>();

    switch (action) {
      case 'edit':
        _showEditDialog(number);
        break;

      case 'activate':
      case 'deactivate':
        try {
          await service.update(id: id, isActive: action == 'activate');
          _load();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(action == 'activate' ? 'Numero active' : 'Numero desactive'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.danger),
            );
          }
        }
        break;

      case 'delete':
        final confirm = await _confirmDialog(
          'Supprimer ce numero ?',
          'Cette action est irreversible.',
        );
        if (confirm != true) return;
        try {
          await service.delete(id);
          _load();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Numero supprime'), backgroundColor: AppColors.success),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.danger),
            );
          }
        }
        break;
    }
  }

  Future<bool?> _confirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    _showFormDialog(null);
  }

  void _showEditDialog(Map<String, dynamic> number) {
    _showFormDialog(number);
  }

  void _showFormDialog(Map<String, dynamic>? existing) {
    final isEdit = existing != null;
    final displayCtrl = TextEditingController(text: existing?['display_name'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone_number'] ?? '');
    String? selectedOperator = existing?['operator'] ?? 'airtel';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Modifier le numero' : 'Ajouter un numero'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedOperator,
                  decoration: const InputDecoration(
                    labelText: 'Operateur',
                    border: OutlineInputBorder(),
                  ),
                  items: _operators.map((op) {
                    return DropdownMenuItem<String>(
                      value: op['key'] as String,
                      child: Text(op['name'] as String),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedOperator = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: displayCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom affiche',
                    hintText: 'Ex: Airtel Money - Jean Dupont',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Numero',
                    hintText: 'Ex: 0991234567',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final display = displayCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                if (display.isEmpty || phone.isEmpty) return;

                // Capturer AVANT le await
                final service = context.read<PaymentNumbersService>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(ctx);

                try {
                  if (isEdit) {
                    await service.update(
                      id: existing['id'] as String,
                      operator: selectedOperator,
                      displayName: display,
                      phoneNumber: phone,
                    );
                  } else {
                    await service.create(
                      operator: selectedOperator!,
                      displayName: display,
                      phoneNumber: phone,
                    );
                  }
                  if (navigator.mounted) navigator.pop();
                  _load();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Numero modifie' : 'Numero ajoute'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.danger),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.mauve),
              child: Text(isEdit ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}