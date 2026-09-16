// =============================================================
// ChefUnitPlus - Requte de paiement FlexPaie
// Envoye  l'endpoint /payment/request
// =============================================================


class PaymentRequest {
  /// Code marchand fourni par FlexPaie
  final String merchant;

  /// '1' = Mobile Money, '2' = Carte bancaire
  final String type;

  /// Numro Mobile Money (ou n carte)
  final String phone;

  /// Montant  dbiter
  final double amount;

  /// Devise : 'USD', 'CDF', ...
  final String currency;

  /// Rfrence interne (ex: ID formation + ID apprenant)
  final String reference;

  /// URL de callback (optionnel) ?" notification serveur ?' serveur
  final String? callbackUrl;

  const PaymentRequest({
    required this.merchant,
    this.type = '1',
    required this.phone,
    required this.amount,
    this.currency = 'USD',
    required this.reference,
    this.callbackUrl,
  });

  // ===========================================================
  // Y FACTORIES
  // ===========================================================
  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      merchant: json['merchant'] ?? '',
      type: json['type'] ?? '1',
      phone: json['phone'] ?? '',
      amount: _parseDouble(json['amount']),
      currency: json['currency'] ?? 'USD',
      reference: json['reference'] ?? '',
      callbackUrl: json['callbackUrl'],
    );
  }

  /// Constructeur spcialis Mobile Money
  factory PaymentRequest.mobileMoney({
    required String merchant,
    required String phone,
    required double amount,
    required String reference,
    String currency = 'USD',
    String? callbackUrl,
  }) =>
      PaymentRequest(
        merchant: merchant,
        type: '1',
        phone: phone,
        amount: amount,
        currency: currency,
        reference: reference,
        callbackUrl: callbackUrl,
      );

  /// Constructeur spcialis Carte bancaire
  factory PaymentRequest.card({
    required String merchant,
    required String cardNumber,
    required double amount,
    required String reference,
    String currency = 'USD',
    String? callbackUrl,
  }) =>
      PaymentRequest(
        merchant: merchant,
        type: '2',
        phone: cardNumber,
        amount: amount,
        currency: currency,
        reference: reference,
        callbackUrl: callbackUrl,
      );

  // ===========================================================
  // Y" S?RIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'merchant': merchant,
        'type': type,
        'phone': phone,
        'amount': amount.toStringAsFixed(2),
        'currency': currency,
        'reference': reference,
        if (callbackUrl != null) 'callbackUrl': callbackUrl,
      };

  // ===========================================================
  // Y"< COPYWITH
  // ===========================================================
  PaymentRequest copyWith({
    String? merchant,
    String? type,
    String? phone,
    double? amount,
    String? currency,
    String? reference,
    String? callbackUrl,
  }) {
    return PaymentRequest(
      merchant: merchant ?? this.merchant,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      reference: reference ?? this.reference,
      callbackUrl: callbackUrl ?? this.callbackUrl,
    );
  }

  // ===========================================================
  // Y" GETTERS
  // ===========================================================
  bool get isMobileMoney => type == '1';
  bool get isCard => type == '2';

  // ===========================================================
  // Y AFFICHAGE
  // ===========================================================
  @override
  String toString() =>
      'PaymentRequest(merchant: $merchant, type: $type, amount: $amount $currency)';

  // ===========================================================
  // Y HELPERS PRIV?S
  // ===========================================================
  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}