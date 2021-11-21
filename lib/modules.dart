/// An item available for purchase from either the `Google Play Store` or `iOS AppStore`
class InAppPurchase {
  final String title;
  final String price;
  final String currency;
  final String productId;
  final String localizedPrice;

  final String? description;
  final String? introductoryPrice;

  /// ios only
  final String? subscriptionPeriodUnitIOS;
  final String? subscriptionPeriodNumberIOS;
  final String? introductoryPriceNumberIOS;
  final String? introductoryPricePaymentModeIOS;
  final String? introductoryPriceNumberOfPeriodsIOS;
  final String? introductoryPriceSubscriptionPeriodIOS;
  final List<DiscountIOS>? discountsIOS;

  /// android only
  final String? introductoryPricePeriodAndroid;
  final int? introductoryPriceCyclesAndroid;
  final String? subscriptionPeriodAndroid;
  final String? freeTrialPeriodAndroid;
  final String? signatureAndroid;
  final double? originalPrice;
  final String? originalJson;
  final String? iconUrl;

  /// Create [InAppPurchase] from a Map that was previously JSON formatted
  InAppPurchase.fromJSON(Map<String, dynamic> json)
      : productId = json['productId'],
        title = json['title'],
        price = json['price'],
        currency = json['currency'],
        localizedPrice = json['localizedPrice'],
        description = json['description'],
        introductoryPrice = json['introductoryPrice'],
        introductoryPricePaymentModeIOS =
            json['introductoryPricePaymentModeIOS'],
        introductoryPriceNumberOfPeriodsIOS =
            json['introductoryPriceNumberOfPeriodsIOS'],
        introductoryPriceSubscriptionPeriodIOS =
            json['introductoryPriceSubscriptionPeriodIOS'],
        introductoryPriceNumberIOS = json['introductoryPriceNumberIOS'],
        subscriptionPeriodNumberIOS = json['subscriptionPeriodNumberIOS'],
        subscriptionPeriodUnitIOS = json['subscriptionPeriodUnitIOS'],
        subscriptionPeriodAndroid = json['subscriptionPeriodAndroid'],
        introductoryPriceCyclesAndroid = json['introductoryPriceCyclesAndroid'],
        introductoryPricePeriodAndroid = json['introductoryPricePeriodAndroid'],
        freeTrialPeriodAndroid = json['freeTrialPeriodAndroid'],
        signatureAndroid = json['signatureAndroid'],
        iconUrl = json['iconUrl'],
        originalJson = json['originalJson'],
        originalPrice = json['originalPrice'],
        discountsIOS = _extractDiscountIOS(json['discounts']);

  static List<DiscountIOS>? _extractDiscountIOS(dynamic json) {
    List? list = json as List?;
    List<DiscountIOS>? discounts;

    if (list != null) {
      discounts = list
          .map<DiscountIOS>(
            (dynamic discount) =>
                DiscountIOS.fromJSON(discount as Map<String, dynamic>),
          )
          .toList();
    }

    return discounts;
  }
}

/// An item which was purchased from either the `Google Play Store` or `iOS AppStore`
class PurchasedItem {
  final String productId;
  final DateTime transactionDate;
  final String transactionReceipt;

  /// transactionId is null just for getPurchaseHistory for android.
  final String? transactionId;

  // Android only
  final String? orderId;
  final String? purchaseToken;
  final String? signatureAndroid;
  final bool? autoRenewingAndroid;
  final bool? isAcknowledgedAndroid;
  final PurchaseState? purchaseStateAndroid;

  // iOS only
  final DateTime? originalTransactionDateIOS;
  final String? originalTransactionIdentifierIOS;
  final TransactionState? transactionStateIOS;

  /// Create [PurchasedItem] from a Map that was previously JSON formatted
  PurchasedItem.fromJSON(Map<String, dynamic> json)
      : productId = json['productId'],
        transactionReceipt = json['transactionReceipt'],
        transactionDate = _extractDate(json['transactionDate'])!,
        transactionId = json['transactionId'],
        purchaseToken = json['purchaseToken'],
        orderId = json['orderId'],
        signatureAndroid = json['signatureAndroid'],
        isAcknowledgedAndroid = json['isAcknowledgedAndroid'],
        autoRenewingAndroid = json['autoRenewingAndroid'],
        purchaseStateAndroid =
            _decodePurchaseStateAndroid(json['purchaseStateAndroid']),
        originalTransactionDateIOS =
            _extractDate(json['originalTransactionDateIOS']),
        originalTransactionIdentifierIOS =
            json['originalTransactionIdentifierIOS'],
        transactionStateIOS =
            _decodeTransactionStateIOS(json['transactionStateIOS']);

  /// Coerce miliseconds since epoch in double, int, or String into DateTime format
  static DateTime? _extractDate(dynamic timestamp) {
    if (timestamp == null || timestamp is! int) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}

class PurchaseError {
  final int responseCode;
  final String code;
  final String? message;
  final String? debugMessage;

  PurchaseError({
    required this.code,
    required this.message,
    required this.responseCode,
    required this.debugMessage,
  });

  PurchaseError.fromJSON(Map<String, dynamic> json)
      : code = json['code'],
        message = json['message'],
        debugMessage = json['debugMessage'],
        responseCode = json['responseCode'];

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "responseCode": responseCode,
        "debugMessage": debugMessage,
      };
}

class ConnectionResult {
  final bool connected;

  ConnectionResult({required this.connected});

  ConnectionResult.fromJSON(Map<String, dynamic> json)
      : connected = json['connected'];

  Map<String, dynamic> toJson() => {"connected": connected};
}

/// See also https://developer.apple.com/documentation/storekit/skpaymenttransactionstate
enum TransactionState {
  /// A transaction that is being processed by the App Store.
  purchasing,

  /// A successfully processed transaction.
  purchased,

  /// A failed transaction.
  failed,

  /// A transaction that restores content previously purchased by the user.
  restored,

  /// A transaction that is in the queue, but its final status is pending external action such as Ask to Buy.
  deferred,
}

TransactionState? _decodeTransactionStateIOS(int? rawValue) {
  switch (rawValue) {
    case 0:
      return TransactionState.purchasing;
    case 1:
      return TransactionState.purchased;
    case 2:
      return TransactionState.failed;
    case 3:
      return TransactionState.restored;
    case 4:
      return TransactionState.deferred;
    default:
      return null;
  }
}

/// See also https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState
enum PurchaseState {
  pending,

  purchased,

  unspecified,
}

PurchaseState? _decodePurchaseStateAndroid(int? rawValue) {
  switch (rawValue) {
    case 0:
      return PurchaseState.unspecified;
    case 1:
      return PurchaseState.purchased;
    case 2:
      return PurchaseState.pending;
    default:
      return null;
  }
}
