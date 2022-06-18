import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/cards/card_base.dart';
import 'package:in_app_purchase_example/components/icons/sku_icon.dart';
import 'package:in_app_purchase_example/components/mixin/snack_bar_mixin.dart';
import 'package:in_app_purchase_example/components/product_component.dart';
import 'package:in_app_purchase_example/skus.dart';

class NonConsumablesCard extends StatefulWidget {
  const NonConsumablesCard({Key? key, required final this.purchasesPlugin})
      : super(key: key);

  final InAppPurchases purchasesPlugin;

  @override
  State<NonConsumablesCard> createState() => _NonConsumablesCardState();
}

class _NonConsumablesCardState extends State<NonConsumablesCard>
    with SnackBarMixin {
  List<InAppPurchase> availableProducts = [];
  List<PurchaseDetails> purchasedProducts = [];
  StreamSubscription<TransactionDetails>? listener;

  bool isInitialized = false;

  static const _titleStyle = TextStyle(
    fontSize: 18.0,
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return CardBase(
      height: 164,
      child: isInitialized
          ? Column(
              children: [
                const Text('Non-Consumables', style: _titleStyle),
                const SizedBox(height: 5.0),
                const Divider(thickness: 0.7),
                ...availableProducts.map<ProductComponent>(
                  (p) {
                    final isPurchased = _isProductPurchased(p.sku);
                    return ProductComponent(
                      text: p.title,
                      icon: Sku.hasIcon(p.sku) ? SkuIcon(sku: p.sku) : null,
                      callback: _startPurchase(p, context),
                      price: isPurchased ? 'Purchased' : p.localizedPrice,
                      buttonColor: isPurchased ? Colors.grey : Colors.green,
                    );
                  },
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _initialize() async {
    await _fetchAvailablePurchases();
    if (mounted) setState(() => isInitialized = true);
  }

  Future<void> _fetchAvailablePurchases() async {
    final available = await widget.purchasesPlugin.getInAppPurchases(
      Sku.nonConsumableIdentifiers,
    );
    if (available.hasValue) availableProducts = available.value;

    final purchased = await widget.purchasesPlugin.getPurchasedProducts();
    if (available.hasValue) {
      purchasedProducts.clear();
      purchasedProducts.addAll(purchased.value);
    }
  }

  VoidCallback _startPurchase(
    final InAppPurchase product,
    final BuildContext context,
  ) =>
      () {
        // Another purchase is beeing processed
        if (listener != null) return;
        widget.purchasesPlugin.startPurchase(product);
        listener = widget.purchasesPlugin
            .purchasesDetailsStreamFor(product.sku)
            .listen((d) => _handlePurchaseDetails(d, context));
      };

  void _handlePurchaseDetails(
    final TransactionDetails details,
    final BuildContext context,
  ) async {
    if (details is PurchaseDetails) {
      widget.purchasesPlugin.finishPurchase(details);
      if (!purchasedProducts.any((product) => product.sku == details.sku)) {
        purchasedProducts.add(details);
        _showSnackbar(details.sku, 'Purchased');
        setState(() {});
      } else {
        _showSnackbar(details.sku, 'Granted for free');
      }
    }

    if (details.state.isFinished) {
      listener?.cancel();
      listener = null;
    }
  }

  bool _isProductPurchased(final String sku) {
    return purchasedProducts.any((p) => p.sku == sku);
  }

  void _showSnackbar(final String sku, final String text) async {
    final icon = SkuIcon(sku: sku, dimension: 23);
    showSnackbar(text, icon: icon);
  }
}
