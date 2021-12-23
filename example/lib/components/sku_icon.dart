import 'package:flutter/material.dart';
import 'package:in_app_purchase_example/components/ads_free.dart';
import 'package:in_app_purchase_example/components/bill.dart';
import 'package:in_app_purchase_example/components/coin.dart';
import 'package:in_app_purchase_example/components/premium_feature.dart';
import 'package:in_app_purchase_example/skus.dart';

class SkuIcon extends StatelessWidget {
  const SkuIcon({
    Key? key,
    required this.sku,
    this.dimension = 20,
  }) : super(key: key);

  final String sku;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    if (sku == Sku.coins.id) {
      return CoinIcon(radius: dimension);
    } else if (sku == Sku.bill.id) {
      return BillIcon(width: dimension);
    } else if (sku == Sku.adsFree.id) {
      return AdsFreeIcon(radius: dimension);
    } else if (sku == Sku.premiumFeature.id) {
      return PremiumFeatureIcon(radius: dimension);
    }

    return const SizedBox.shrink();
  }
}
