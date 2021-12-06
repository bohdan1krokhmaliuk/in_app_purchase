import 'package:in_app_purchase/models/base/transaction_state.dart';

abstract class TransactionDetails {
  /// The string that identifies the product to the Apple App Store or Google Play Store.
  String get sku;

  /// Account identifier that were provided when the purchase was made.
  String? get obfuscatedAccountId;

  TransactionState get state;
}

// TODO:
/// Identifies failed product details
/// Possible [TransactionState] values: .canceled, .errored
// abstract class FailedDetails implements TransactionDetails {}

/// Identifies purchased product details
/// Possible [TransactionState] values: .purchased
abstract class PurchaseDetails implements TransactionDetails {
  String get receipt;

  /// Returns the quantity of the purchased product.
  int get quantity;

  String get transactionId;

  /// Time the product was purchased.
  DateTime get transactionDate;
}

/// Identifies restored product details
/// Possible [TransactionState] values: .restored
abstract class RestoreDetails implements PurchaseDetails {}
