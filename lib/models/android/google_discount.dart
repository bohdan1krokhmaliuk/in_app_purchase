import 'package:in_app_purchase/models/base/discount.dart';
import 'package:in_app_purchase/models/base/period.dart';

class GoogleDiscount extends Discount {
  @override
  final int numberOfPeriods;

  @override
  final Period period;

  @override
  final String currency;

  @override
  final double price;

  @override
  final String localizedPrice;

  /// Create [GoogleDiscount] from a Map that was previously JSON formatted
  GoogleDiscount.fromJSON(Map<String, dynamic> json)
      : price = json['price'],
        currency = json['currency'],
        localizedPrice = json['localizedPrice'],
        numberOfPeriods = json['numberOfPeriods'],
        period = Period.fromIso8601(json['period'])!;
}
