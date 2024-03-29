import 'package:in_app_purchase/models/base/discount.dart';
import 'package:in_app_purchase/models/base/period.dart';
import 'package:in_app_purchase/models/base/period_unit.dart';

enum DiscountType { introductory, subscription, unknown }

extension _DiscountTypeExt on DiscountType {
  static DiscountType init(final int rawValue) {
    switch (rawValue) {
      case 0:
        return DiscountType.introductory;
      case 1:
        return DiscountType.subscription;
      default:
        return DiscountType.unknown;
    }
  }

  int get rawValue {
    switch (this) {
      case DiscountType.introductory:
        return 0;
      case DiscountType.subscription:
        return 1;
      default:
        return -1;
    }
  }
}

enum PaymentMode { payAsYouGo, payUpFront, freeTrial, unknown }

extension _PaymentModeExt on PaymentMode {
  static PaymentMode init(final int rawValue) {
    switch (rawValue) {
      case 0:
        return PaymentMode.payAsYouGo;
      case 1:
        return PaymentMode.payUpFront;
      case 2:
        return PaymentMode.freeTrial;
      default:
        return PaymentMode.unknown;
    }
  }

  int get rawValue {
    switch (this) {
      case PaymentMode.payAsYouGo:
        return 0;
      case PaymentMode.payUpFront:
        return 1;
      case PaymentMode.freeTrial:
        return 2;
      default:
        return -1;
    }
  }
}

class AppleDiscount implements Discount {
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

  /// A string used to uniquely identify a discount offer for a product.
  /// You set up offers and their identifiers in App Store Connect.
  final String? identifier;

  /// The type of discount offer
  final DiscountType type;

  ///The payment mode indicates how the product discount price is charged:
  /// One or more times, for [PaymentMode.payAsYouGo] mode
  /// No initial charge, for [PaymentMode.freeTrial] mode
  /// Once in advance, for [PaymentMode.payUpFront] mode
  final PaymentMode paymentMode;

  /// Create [AppleDiscount] from a Map that was previously JSON formatted
  AppleDiscount.fromJSON(Map<String, dynamic> json)
      : price = json['price'],
        currency = json['currency'],
        identifier = json['identifier'],
        localizedPrice = json['localizedPrice'],
        numberOfPeriods = json['numberOfPeriods'],
        type = _DiscountTypeExt.init(json['type']),
        paymentMode = _PaymentModeExt.init(json['paymentMode']),
        period = Period(
          numberOfUnits: json['numberOfUnits'],
          periodUnit: PeriodUnitExt.init(json['periodUnit']),
        );

  Map<String, dynamic> toJSON() => {
        'price': price,
        'currency': currency,
        'type': type.rawValue,
        'identifier': identifier,
        'localizedPrice': localizedPrice,
        'numberOfPeriods': numberOfPeriods,
        'paymentMode': paymentMode.rawValue,
        'numberOfUnits': period.numberOfUnits,
        'periodUnit': period.periodUnit.rawValue,
      };
}
