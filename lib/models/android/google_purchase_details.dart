import 'package:in_app_purchase/models/base/purchase_details.dart';

class GooglePurchaseDetails extends PurchaseDetails {
  @override
  final String sku;

  @override
  final DateTime? transactionDate;

  @override
  final String? transactionId;

  @override
  final String receipt;

  @override
  final int quantity;

  @override
  final String? obfuscatedAccountId;

  /// Profile identifier that were provided when the purchase was made.
  final String? obfuscatedProfileId;

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

  // TODO: state

  ApplePurchaseDetails.fromJson(final Map<String, dynamic> json)
      : sku = json['sku'],
        receipt = json['receipt'],
        transactionId = json['transactionId'],
        transactionDate = DateExtractor.extractDate(json['date']),
        originalTransactionId = json['originalTransactionIdentifier'],
        originalDate = DateExtractor.extractDate(
          json['originalTransactionDate'],
        );
}