import 'package:in_app_purchase/mixins/date_extractor.dart';
import 'package:in_app_purchase/models/base/purchase_details.dart';

class ApplePurchaseDetails extends PurchaseDetails {
  @override
  final String sku;

  /// The date the transaction was added to the App Store’s payment queue.
  @override
  final DateTime? transactionDate;

  /// The contents of this property are undefined except when transactionState
  /// is set to .purchased or .restored. The transactionIdentifier is a string
  /// that uniquely identifies an interaction between the user's device and the
  /// App Store, such as a purchase or restore.
  ///
  /// This value has the same format as the transaction’s transaction_id in the
  /// receipt; however, the values may not be the same.
  @override
  final String? transactionId;

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

  /// The default value is 1, the minimum value is 1, and the maximum value is 10.
  @override
  final int quantity;

  @override
  final String receipt;

  /// When a transaction is restored, the current transaction holds a new
  /// transaction identifier, receipt, and so on. [originalDate] is date of
  /// original transaction.
  final DateTime? originalDate;

  /// When a transaction is restored, the current transaction holds a new
  /// transaction identifier, receipt, and so on. [originalTransactionId] is
  /// id of the original transaction.
  final String? originalTransactionId;

  // TODO: state

  ApplePurchaseDetails.fromJson(final Map<String, dynamic> json)
      : sku = json['sku'],
        receipt = json['receipt'],
        quantity = json['quantity'],
        transactionId = json['transactionId'],
        obfuscatedAccountId = json['applicationUsername'],
        transactionDate = DateExtractor.extractDate(json['date']),
        originalTransactionId = json['originalTransactionIdentifier'],
        originalDate = DateExtractor.extractDate(
          json['originalTransactionDate'],
        );
}
