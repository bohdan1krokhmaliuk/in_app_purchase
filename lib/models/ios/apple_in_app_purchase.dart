import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/period.dart';
import 'package:in_app_purchase/models/base/period_unit.dart';
import 'package:in_app_purchase/models/ios/apple_discount.dart';

class AppleInAppPurchase implements InAppPurchase {
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

  /// If you've set up introductory prices in App Store Connect, the introductory
  /// price property will be populated. This property is nil if the product has no
  /// introductory price.
  ///
  /// Before displaying UI that offers the introductory price, you must first
  /// determine if the user is eligible to receive it. See Implementing
  /// Introductory Offers in Your App for information on determining eligibility
  ///  and displaying introductory prices.
  @override
  final AppleDiscount? introductoryDiscount;

  /// The identifier of the subscription group to which the subscription belongs.
  final String? subscriptionGroupId;

  /// The discounts array contains all of the introductory offers and promotional
  /// offers that you set up in App Store Connect for this subscription (productIdentifier).
  /// It's up to the logic in your app to decide which offer to present to the user.
  final List<AppleDiscount> discounts;

  AppleInAppPurchase.fromJson(Map<String, dynamic> json)
      : sku = json['sku'],
        price = json['price'],
        title = json['title'],
        currency = json['currency'],
        description = json['description'],
        localizedPrice = json['localizedPrice'],
        subscriptionGroupId = json['subscriptionGroupId'],
        subscriptionPeriod = json['subscriptionPeriodUnit'] == null
            ? null
            : Period(
                periodUnit: PeriodUnitExt.init(json['subscriptionPeriodUnit']),
                numberOfUnits: json['subscriptionPeriodNumber'],
              ),
        discounts = _convertFromList(
          (json['discounts'] as List?)
                  ?.map<Map<String, dynamic>>(
                    (j) => Map<String, dynamic>.from(j),
                  )
                  .toList() ??
              <Map<String, dynamic>>[],
        ),
        introductoryDiscount = json['introductoryDiscount'] != null
            ? AppleDiscount.fromJSON(
                Map<String, dynamic>.from(json['introductoryDiscount']),
              )
            : null;

  static List<AppleDiscount> _convertFromList(
    final List<Map<String, dynamic>> list,
  ) {
    return list.map<AppleDiscount>((l) => AppleDiscount.fromJSON(l)).toList();
  }
}
