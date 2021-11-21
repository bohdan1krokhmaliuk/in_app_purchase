import 'package:in_app_purchase/models/android/google_discount.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/period.dart';

class GoogleInAppPurchase extends InAppPurchase {
  @override
  final String sku;

  @override
  final double price;

  @override
  final String currency;

  @override
  final String localizedPrice;

  @override
  final String title;

  @override
  final String description;

  @override
  final Period? subscriptionPeriod;

  @override
  final GoogleDiscount? introductoryDiscount;

  final String? iconUrl;

  final Period? freeTrialPeriod;

  final double originalPrice;

  final String originalLocalizedPrice;

  GoogleInAppPurchase.fromJSON(Map<String, dynamic> json)
      : sku = json['sku'],
        price = json['price'],
        title = json['title'],
        iconUrl = json['iconUrl'],
        currency = json['currency'],
        description = json['description'],
        originalPrice = json['originalPrice'],
        localizedPrice = json['localizedPrice'],
        originalLocalizedPrice = json['originalLocalizedPrice'],
        freeTrialPeriod = Period.fromIso8601(json['freeTrial']),
        subscriptionPeriod = Period.fromIso8601(json['subscriptionPeriod']),
        introductoryDiscount = json['introductoryDiscount'] != null
            ? GoogleDiscount.fromJSON(json['introductoryDiscount'])
            : null;
}
