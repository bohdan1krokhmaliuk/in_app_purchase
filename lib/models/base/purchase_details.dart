abstract class PurchaseDetails {
  /// The string that identifies the product to the Apple App Store or Google Play Store.
  String get sku;

  String get receipt;

  String? get transactionId;

  /// Account identifier that were provided when the purchase was made.
  String? get obfuscatedAccountId;

  /// Time the product was purchased.
  DateTime? get transactionDate;

  /// Returns the quantity of the purchased product.
  int get quantity;
}
