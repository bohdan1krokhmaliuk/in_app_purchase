import 'package:flutter/material.dart';
import 'package:in_app_purchase_example/components/bill.dart';
import 'package:in_app_purchase_example/components/coin.dart';
import 'package:in_app_purchase_example/skus.dart';

class SkuIcon extends StatelessWidget {
  const SkuIcon({
    Key? key,
    required this.sku,
    this.dimension = 33,
  }) : super(key: key);

  final String sku;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    if (sku == Sku.coins.id) {
      return Coin(radius: dimension);
    } else if (sku == Sku.bill.id) {
      return Bill(width: dimension);
    }

    return const SizedBox.shrink();
  }
}
