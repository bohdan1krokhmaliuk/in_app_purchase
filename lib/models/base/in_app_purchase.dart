import 'package:in_app_purchase/models/base/discount.dart';
import 'package:in_app_purchase/models/base/period.dart';

abstract class InAppPurchase {
  /// The string that identifies the product to the Apple App Store or Google Play Store
  String get sku;

  /// The cost of the product in the [currency]
  double get price;

  /// The currency code ISO 4217
  String get currency;

  /// Formatted price for in app purchase locale
  String get localizedPrice;

  /// The name of the in app purhcase
  /// The title's language is determined by the storefront that the user's device is connected to, not the preferred language set on the device
  String get title;

  /// The description of in app purhcase
  String get description;

  /// SubscriptionCycle if subscription in app purchase
  Period? get subscriptionPeriod;

  /// Introductory discount for in app purchase
  Discount? get introductoryDiscount;
}
