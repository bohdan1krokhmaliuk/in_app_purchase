import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';

abstract class GoogleTransactionDetails implements TransactionDetails {
  const GoogleTransactionDetails._({
    required this.sku,
    required this.skus,
    required this.packageName,
    required this.developerPayload,
    required this.purchaseToken,
    required this.signature,
    required this.isAcknowledged,
    required this.isAutoRenewing,
    required this.state,
    this.obfuscatedAccountId,
    this.obfuscatedProfileId,
  });

  /// While android-billing doesn't support multiple in app purchases per 1
  /// transaction (current version: v4.0.0). [sku] will be always equal to
  /// purchase sku. However when multiple iaps will be added sku will be first
  /// element of [skus] by default.
  @override
  final String sku;

  @override
  final TransactionState state;

  @override
  final String? obfuscatedAccountId;

  /// Profile identifier that were provided when the purchase was made.
  final String? obfuscatedProfileId;

  /// List of skus in current transaction
  final List<String> skus;

  /// Returns the payload specified when the purchase was acknowledged or consumed.
  final String developerPayload;

  /// Returns the application package from which the purchase originated.
  final String packageName;

  /// Returns a token that uniquely identifies a purchase for a given item and user pair.
  final String purchaseToken;

  /// Returns String containing the signature of the purchase data that was signed with the private key of the developer.
  final String signature;

  /// Indicates whether the purchase has been acknowledged.
  final bool isAcknowledged;

  /// Indicates whether the subscription renews automatically
  final bool isAutoRenewing;
}

class GooglePurchaseDetails extends GoogleTransactionDetails
    implements PurchaseDetails {
  const GooglePurchaseDetails._({
    required final this.transactionDate,
    required final this.transactionId,
    required final this.quantity,
    required final this.receipt,
    required final String sku,
    required final String signature,
    required final List<String> skus,
    required final String packageName,
    required final bool isAcknowledged,
    required final bool isAutoRenewing,
    required final String purchaseToken,
    required final String developerPayload,
    final String? obfuscatedAccountId,
    final String? obfuscatedProfileId,
  }) : super._(
          sku: sku,
          skus: skus,
          signature: signature,
          packageName: packageName,
          purchaseToken: purchaseToken,
          isAcknowledged: isAcknowledged,
          isAutoRenewing: isAutoRenewing,
          state: TransactionState.purchased,
          developerPayload: developerPayload,
          obfuscatedAccountId: obfuscatedAccountId,
          obfuscatedProfileId: obfuscatedProfileId,
        );

  factory GooglePurchaseDetails.fromJson(final Map<String, dynamic> json) =>
      GoogleRestoreDetails._(
        receipt: json['receipt'],
        quantity: json['quantity'],
        signature: json['signature'],
        purchaseToken: json['token'],
        packageName: json['packageName'],
        developerPayload: json['payload'],
        transactionId: json['transactionId'],
        skus: List<String>.from(json['skus']),
        isAcknowledged: json['isAcknowledged'],
        isAutoRenewing: json['isAutoRenewing'],
        sku: List<String>.from(json['skus']).first,
        obfuscatedAccountId: json['obfuscatedAccountId'],
        obfuscatedProfileId: json['obfuscatedProfileId'],
        transactionDate: DateTime.fromMillisecondsSinceEpoch(json['date']),
      );

  @override
  final DateTime transactionDate;

  @override
  final String transactionId;

  @override
  final String receipt;

  @override
  final int quantity;
}

class GoogleRestoreDetails extends GooglePurchaseDetails
    implements RestoreDetails {
  const GoogleRestoreDetails._({
    required final DateTime transactionDate,
    required final String transactionId,
    required final String receipt,
    required final String sku,
    required final int quantity,
    required final String signature,
    required final List<String> skus,
    required final String packageName,
    required final bool isAcknowledged,
    required final bool isAutoRenewing,
    required final String purchaseToken,
    required final String developerPayload,
    final String? obfuscatedAccountId,
    final String? obfuscatedProfileId,
  }) : super._(
          sku: sku,
          skus: skus,
          receipt: receipt,
          quantity: quantity,
          signature: signature,
          packageName: packageName,
          transactionId: transactionId,
          purchaseToken: purchaseToken,
          isAcknowledged: isAcknowledged,
          isAutoRenewing: isAutoRenewing,
          transactionDate: transactionDate,
          developerPayload: developerPayload,
          obfuscatedAccountId: obfuscatedAccountId,
          obfuscatedProfileId: obfuscatedProfileId,
        );

  factory GoogleRestoreDetails.fromJson(final Map<String, dynamic> json) =>
      GoogleRestoreDetails._(
        receipt: json['receipt'],
        quantity: json['quantity'],
        signature: json['signature'],
        purchaseToken: json['token'],
        packageName: json['packageName'],
        developerPayload: json['payload'],
        transactionId: json['transactionId'],
        skus: List<String>.from(json['skus']),
        isAcknowledged: json['isAcknowledged'],
        isAutoRenewing: json['isAutoRenewing'],
        sku: List<String>.from(json['skus']).first,
        obfuscatedAccountId: json['obfuscatedAccountId'],
        obfuscatedProfileId: json['obfuscatedProfileId'],
        transactionDate: DateTime.fromMillisecondsSinceEpoch(json['date']),
      );
}
