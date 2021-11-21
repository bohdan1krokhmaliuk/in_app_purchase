import 'package:in_app_purchase/mixins/date_extractor.dart';
import 'package:in_app_purchase/models/base/purchase_details.dart';

class GooglePurchaseDetails extends PurchaseDetails {
  /// While android-billing doesn't support multiple in app purchases per 1
  /// transaction (current version: v4.0.0). [sku] will be always equal to
  /// purchase sku. However when multiple iaps will be added sku will be first
  /// element of [skus] by default.
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

  /// List of skus in current transaction
  final List<String> skus;

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

  GooglePurchaseDetails.fromJson(final Map<String, dynamic> json)
      : skus = List<String>.from(json['skus']),
        sku = List<String>.from(json['skus']).first,
        receipt = json['receipt'],
        quantity = json['quantity'],
        signature = json['signature'],
        packageName = json['packageName'],
        transactionId = json['transactionId'],
        purchaseToken = json['purchaseToken'],
        isAcknowledged = json['isAcknowledged'],
        isAutoRenewing = json['isAutoRenewing'],
        developerPayload = json['developerPayload'],
        obfuscatedAccountId = json['obfuscatedAccountId'],
        obfuscatedProfileId = json['obfuscatedProfileId'],
        transactionDate = DateExtractor.extractDate(json['date']);
}
