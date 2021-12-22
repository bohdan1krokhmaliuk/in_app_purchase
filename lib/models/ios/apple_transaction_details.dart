import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';

abstract class AppleTransactionDetails implements TransactionDetails {
  const AppleTransactionDetails._({
    required this.sku,
    required this.state,
    this.obfuscatedAccountId,
  });

  @override
  final String sku;

  /// You can use this property to detect some forms of fraudulent activity,
  /// typically multiple transactions from different iTunes Store accounts.
  /// For example, if you have an online game where each user creates
  /// an account to save gameplay data, it's unusual for many different
  /// iTunes Store accounts to make purchases on behalf of the same user account
  /// on your system. The App Store can't automatically detect that the
  /// transactions are related. Setting this property associates the purchases
  /// with each other.
  @override
  final String? obfuscatedAccountId;

  /// When a transaction is restored, the current transaction holds a new
  /// transaction identifier, receipt, and so on. [originalDate] is date of
  /// original transaction.
  // final DateTime? originalDate;

  /// When a transaction is restored, the current transaction holds a new
  /// transaction identifier, receipt, and so on. [originalTransactionId] is
  /// id of the original transaction.
  // final String? originalTransactionId;

  @override
  final TransactionState state;
}

class ApplePurchaseDetails extends AppleTransactionDetails
    implements PurchaseDetails {
  const ApplePurchaseDetails._({
    required final this.receipt,
    required final this.quantity,
    required final this.transactionId,
    required final this.transactionDate,
    required final String sku,
    final String? obfuscatedAccountId,
  }) : super._(
          sku: sku,
          state: TransactionState.purchased,
          obfuscatedAccountId: obfuscatedAccountId,
        );

  factory ApplePurchaseDetails.fromJson(final Map<String, dynamic> json) =>
      ApplePurchaseDetails._(
        sku: json['sku'],
        receipt: json['receipt'],
        quantity: json['quantity'],
        transactionId: json['transactionId'],
        obfuscatedAccountId: json['applicationUsername'],
        transactionDate: DateTime.fromMillisecondsSinceEpoch(json['date']),
      );

  /// The date the transaction was added to the App Store’s payment queue.
  @override
  final DateTime transactionDate;

  /// The contents of this property are undefined except when transactionState
  /// is set to .purchased or .restored. The transactionIdentifier is a string
  /// that uniquely identifies an interaction between the user's device and the
  /// App Store, such as a purchase or restore.
  ///
  /// This value has the same format as the transaction’s transaction_id in the
  /// receipt; however, the values may not be the same.
  @override
  final String transactionId;

  @override
  final String receipt;

  /// The default value is 1, the minimum value is 1, and the maximum value is 10.
  @override
  final int quantity;
}

class AppleRestoreDetails extends ApplePurchaseDetails
    implements RestoreDetails {
  const AppleRestoreDetails._({
    required this.originalDate,
    required this.originalTransactionId,
    required final String sku,
    required final int quantity,
    required final String receipt,
    required final String transactionId,
    required final DateTime transactionDate,
    final String? obfuscatedAccountId,
  }) : super._(
          sku: sku,
          receipt: receipt,
          quantity: quantity,
          transactionId: transactionId,
          transactionDate: transactionDate,
          obfuscatedAccountId: obfuscatedAccountId,
        );

  factory AppleRestoreDetails.fromJson(final Map<String, dynamic> json) =>
      AppleRestoreDetails._(
        sku: json['sku'],
        receipt: json['receipt'],
        quantity: json['quantity'],
        transactionId: json['transactionId'],
        obfuscatedAccountId: json['applicationUsername'],
        originalTransactionId: json['originalTransactionIdentifier'],
        transactionDate: DateTime.fromMillisecondsSinceEpoch(json['date']),
        originalDate: DateTime.fromMillisecondsSinceEpoch(
          json['originalTransactionDate'],
        ),
      );

  /// When a transaction is restored, the current transaction holds a new
  /// transaction identifier, receipt, and so on. [originalDate] is date of
  /// original transaction.
  final DateTime originalDate;

  /// When a transaction is restored, the current transaction holds a new
  /// transaction identifier, receipt, and so on. [originalTransactionId] is
  /// id of the original transaction.
  final String originalTransactionId;
}
