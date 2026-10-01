// =============================================================
// ChefUnitPlus - InactivityDetector
// Deconnecte automatiquement l'utilisateur apres N minutes
// d'inactivite (aucune interaction : tap, scroll, saisie)
// =============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class InactivityDetector extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback? onTimeout;
  final bool enabled;

  const InactivityDetector({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 5),
    this.onTimeout,
    this.enabled = true,
  });

  @override
  State<InactivityDetector> createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends State<InactivityDetector> {
  Timer? _timer;
  DateTime? _lastActivity;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _resetTimer();
    }
  }

  @override
  void didUpdateWidget(InactivityDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.timeout != widget.timeout) {
      if (widget.enabled) {
        _resetTimer();
      } else {
        _timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    if (!widget.enabled) return;

    _timer?.cancel();
    _lastActivity = DateTime.now();
    _timer = Timer(widget.timeout, _onInactivity);
  }

  Future<void> _onInactivity() async {
    if (!mounted) return;

    final auth = context.read<AuthController>();
    if (!auth.isAuthenticated) {
      _resetTimer();
      return;
    }

    widget.onTimeout?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_clock, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Session expiree apres ${widget.timeout.inMinutes} min '
                  'd\'inactivite. Reconnectez-vous.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    await auth.logout();
  }

  void _onUserInteraction() {
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerSignal: (_) => _onUserInteraction(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _onUserInteraction();
          return false;
        },
        child: widget.child,
      ),
    );
  }
}