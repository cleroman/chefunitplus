import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/payment_request.dart';
import '../models/payment_response.dart';

class PaymentService {
  PaymentService();

  /// Initier un paiement FlexPaie
  Future<PaymentResponse> initiate(PaymentRequest request) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.flexPaieBaseUrl}${ApiConstants.flexPaieInitiate}',
      );
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConstants.flexPaieToken}',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return PaymentResponse.error('Erreur serveur (${response.statusCode})');
    } catch (e, st) {
      ErrorHandler.log(e, st, 'PaymentService.initiate');
      return PaymentResponse.error('Erreur réseau : $e');
    }
  }

  /// Vérifier le statut d'une commande
  Future<PaymentResponse> checkStatus(String orderNumber) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.flexPaieBaseUrl}${ApiConstants.flexPaieCheck.replaceAll('{orderNumber}', orderNumber)}',
      );
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${ApiConstants.flexPaieToken}'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return PaymentResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return PaymentResponse.error('Vérification échouée');
    } catch (e, st) {
      ErrorHandler.log(e, st, 'PaymentService.checkStatus');
      return PaymentResponse.error('Erreur réseau : $e');
    }
  }

  /// Polling jusqu'à succès/échec/expiration.
  ///
  /// Le callback `onUpdate` reçoit la réponse ET le numéro de tentative
  /// en cours. Retourne toujours une [PaymentResponse] (jamais null).
  Future<PaymentResponse> pollUntilComplete({
    required String orderNumber,
    Duration interval = const Duration(seconds: 5),
    int maxAttempts = 24,
    void Function(PaymentResponse response, int attempt)? onUpdate,
  }) async {
    try {
      int attempts = 0;

      while (attempts < maxAttempts) {
        await Future.delayed(interval);
        attempts++;

        final response = await checkStatus(orderNumber);

        onUpdate?.call(response, attempts);

        if (response.isSuccess || response.isFailure) {
          return response;
        }
      }

      final timeout = PaymentResponse.error(
        'Délai dépassé. Validation non reçue.',
      );
      onUpdate?.call(timeout, attempts);
      return timeout;
    } catch (e, st) {
      ErrorHandler.log(e, st, 'PaymentService.pollUntilComplete');
      final error = PaymentResponse.error('Erreur de vérification : $e');
      onUpdate?.call(error, 0);
      return error;
    }
  }
}