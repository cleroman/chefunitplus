// =============================================================
// ChefUnitPlus - PaymentController
// Initiation FlexPaie + polling jusqu' validation
// =============================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/payment_request.dart';
import '../models/payment_response.dart';
import '../services/payment_service.dart';
import 'package:flutter/material.dart';

enum PaymentState {
  idle,
  loading, // initiation en cours
  waitingPin, // en attente de saisie PIN utilisateur
  success,
  error,
}

class PaymentController extends ChangeNotifier {
  final PaymentService _service;

  PaymentController({required PaymentService service}) : _service = service;

  PaymentState _state = PaymentState.idle;
  PaymentResponse? _response;
  String? _errorMessage;
  Timer? _timer;

  PaymentState get state => _state;
  PaymentResponse? get response => _response;
  String? get errorMessage => _errorMessage;

  bool get isBusy =>
      _state == PaymentState.loading || _state == PaymentState.waitingPin;
  bool get isSuccess => _state == PaymentState.success;
  bool get isFailure => _state == PaymentState.error;

  // ===========================================================
  // Ys? D?MARRAGE DU PAIEMENT
  // ===========================================================
  Future<bool> startPayment({
    required String phone,
    required double amount,
    required String reference,
    String currency = 'USD',
    String type = '1', // '1' Mobile Money, '2' Carte
    void Function(PaymentResponse response, int attempt)? onProgress,
  }) async {
    // Reset
    _state = PaymentState.loading;
    _response = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = PaymentRequest(
        merchant: ApiConstants.flexPaieMerchant,
        type: type,
        phone: phone,
        amount: amount,
        currency: currency,
        reference: reference,
      );

      // 1. Initiation
      final initResponse = await _service.initiate(request);
      _response = initResponse;

      // ?chec initiation
      if (!initResponse.hasOrderNumber) {
        _state = PaymentState.error;
        _errorMessage = initResponse.message ?? 'Paiement non initi';
        notifyListeners();
        return false;
      }

      // 2. Attente PIN
      _state = PaymentState.waitingPin;
      notifyListeners();

      // 3. Polling automatique
      final finalResponse = await _service.pollUntilComplete(
        orderNumber: initResponse.orderNumber!,
        interval: const Duration(seconds: 5),
        maxAttempts: 24,
        onUpdate: onProgress,
      );

      _response = finalResponse;

      if (finalResponse.isSuccess) {
        _state = PaymentState.success;
        notifyListeners();
        return true;
      } else {
        _state = PaymentState.error;
        _errorMessage = finalResponse.displayMessage;
        notifyListeners();
        return false;
      }
    } catch (e, st) {
      _state = PaymentState.error;
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'PaymentController.startPayment');
      notifyListeners();
      return false;
    }
  }

  // ===========================================================
  // Y"" V?RIFICATION MANUELLE
  // ===========================================================
  Future<bool> checkStatus(String orderNumber) async {
    try {
      final response = await _service.checkStatus(orderNumber);
      _response = response;
      if (response.isSuccess) {
        _state = PaymentState.success;
      } else if (response.isFailure) {
        _state = PaymentState.error;
        _errorMessage = response.displayMessage;
      }
      notifyListeners();
      return response.isSuccess;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'PaymentController.checkStatus');
      notifyListeners();
      return false;
    }
  }

  // ===========================================================
  // Y" RESET
  // ===========================================================
  void reset() {
    _timer?.cancel();
    _state = PaymentState.idle;
    _response = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}