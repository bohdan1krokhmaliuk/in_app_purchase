import 'package:in_app_purchase/models/base/period.dart';

abstract class Discount {
  /// An integer that indicates the number of periods the product discount is available.
  int get numberOfPeriods;

  /// Cycle period in which subscription payment is repeated.
  Period get period;

  /// The currency code ISO 4217
  String get currency;

  /// The discount price of the product in the local currency
  double get price;

  /// Formatted price for discount locale
  String get localizedPrice;
}
