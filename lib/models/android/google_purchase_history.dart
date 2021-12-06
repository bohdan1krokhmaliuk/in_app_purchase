class GooglePurchaseHistoryRecord {
  const GooglePurchaseHistoryRecord._({
    required final this.sku,
    required final this.skus,
    required final this.developerPayload,
    required final this.purchaseToken,
    required final this.signature,
    required final this.quantity,
    required final this.receipt,
    required final this.transactionDate,
  });

  factory GooglePurchaseHistoryRecord.fromJson(
    final Map<String, dynamic> json,
  ) =>
      GooglePurchaseHistoryRecord._(
        receipt: json['receipt'],
        quantity: json['quantity'],
        signature: json['signature'],
        purchaseToken: json['token'],
        developerPayload: json['payload'],
        skus: List<String>.from(json['skus']),
        sku: List<String>.from(json['skus']).first,
        transactionDate: DateTime.fromMillisecondsSinceEpoch(json['date']),
      );

  /// While android-billing doesn't support multiple in app purchases per 1
  /// transaction (current version: v4.0.0). [sku] will be always equal to
  /// purchase sku. However when multiple iaps will be added sku will be first
  /// element of [skus] by default.
  final String sku;

  /// List of skus in current transaction
  final List<String> skus;

  /// Returns String containing the signature of the purchase data that was signed with the private key of the developer.
  final String signature;

  /// Returns a token that uniquely identifies a purchase for a given item and user pair.
  final String purchaseToken;

  /// Returns the payload specified when the purchase was acknowledged or consumed.
  final String developerPayload;

  final int quantity;

  final String receipt;

  final DateTime transactionDate;
}
