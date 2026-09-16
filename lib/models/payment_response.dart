// =============================================================
// ChefUnitPlus - Rponse FlexPaie
// Renvoye par /payment/request et /payment/check/{orderNumber}
// status : '0' = succs, autres = chec
// =============================================================


class PaymentResponse {
  final String status;
  final String? message;
  final String? statusDescription;
  final String? orderNumber;
  final String? reference;
  final double? amount;
  final String? currency;
  final String? transactionId;
  final DateTime? createdAt;

  const PaymentResponse({
    required this.status,
    this.message,
    this.statusDescription,
    this.orderNumber,
    this.reference,
    this.amount,
    this.currency,
    this.transactionId,
    this.createdAt,
  });

  // ===========================================================
  // Y FACTORIES
  // ===========================================================
  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      status: json['status']?.toString() ?? '-1',
      message: json['message'],
      statusDescription: json['statusDescription'],
      orderNumber: json['orderNumber'],
      reference: json['reference'],
      amount: _parseDoubleOrNull(json['amount']),
      currency: json['currency'],
      transactionId: json['transactionId'],
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// Rponse en cas d'erreur locale / rseau
  factory PaymentResponse.error(String message) =>
      PaymentResponse(status: '-1', message: message);

  /// Rponse en attente
  factory PaymentResponse.pending(String orderNumber) => PaymentResponse(
        status: '1',
        message: 'Paiement en attente de validation',
        orderNumber: orderNumber,
      );

  // ===========================================================
  // Y" S?RIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'status': status,
        if (message != null) 'message': message,
        if (statusDescription != null) 'statusDescription': statusDescription,
        if (orderNumber != null) 'orderNumber': orderNumber,
        if (reference != null) 'reference': reference,
        if (amount != null) 'amount': amount.toString(),
        if (currency != null) 'currency': currency,
        if (transactionId != null) 'transactionId': transactionId,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  // ===========================================================
  // Y"< COPYWITH
  // ===========================================================
  PaymentResponse copyWith({
    String? status,
    String? message,
    String? statusDescription,
    String? orderNumber,
    String? reference,
    double? amount,
    String? currency,
    String? transactionId,
    DateTime? createdAt,
  }) {
    return PaymentResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      statusDescription: statusDescription ?? this.statusDescription,
      orderNumber: orderNumber ?? this.orderNumber,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===========================================================
  // Y" GETTERS
  // ===========================================================
  bool get isSuccess => status == '0';
  bool get isPending => status == '1';
  bool get isFailure => status != '0' && status != '1';

  bool get hasOrderNumber => orderNumber != null && orderNumber!.isNotEmpty;

  String get displayMessage =>
      message ?? statusDescription ?? 'Statut inconnu';

  String? get amountLabel {
    if (amount == null) return null;
    return '\$${amount!.toStringAsFixed(2)} ${currency ?? ''}'.trim();
  }

  // ===========================================================
  // Y AFFICHAGE
  // ===========================================================
  @override
  String toString() =>
      'PaymentResponse(status: $status, order: $orderNumber, message: $displayMessage)';

  // ===========================================================
  // Y HELPERS PRIV?S
  // ===========================================================
  static double? _parseDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}