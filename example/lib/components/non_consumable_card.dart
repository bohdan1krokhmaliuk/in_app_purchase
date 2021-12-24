import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/product_component.dart';
import 'package:in_app_purchase_example/components/sku_icon.dart';
import 'package:in_app_purchase_example/skus.dart';

class NonConsumablesCard extends StatefulWidget {
  const NonConsumablesCard({Key? key, required final this.purchasesPlugin})
      : super(key: key);

  final InAppPurchases purchasesPlugin;

  @override
  State<NonConsumablesCard> createState() => _NonConsumablesCardState();
}

class _NonConsumablesCardState extends State<NonConsumablesCard> {
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
    return Card(
      elevation: 8,
      child: Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: isInitialized
            ? Column(
                children: [
                  const Text('Non-Consumables', style: _titleStyle),
                  const SizedBox(height: 11),
                  const Divider(thickness: 1.0, indent: 16.0, endIndent: 16.0),
                  ...availableProducts.map<ProductComponent>(
                    (p) => ProductComponent(
                      text: p.title,
                      icon: SkuIcon(sku: p.sku),
                      callback: _startPurchase(p, context),
                      price: _isProductPurchased(p.sku)
                          ? 'Purchased'
                          : p.localizedPrice,
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
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
        _showSnackbar(details.sku, 'Purchased', context);
        setState(() {});
      } else {
        _showSnackbar(details.sku, 'Granted for free', context);
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

  void _showSnackbar(
    final String sku,
    final String text,
    final BuildContext context,
  ) async {
    final icon = SkuIcon(sku: sku, dimension: 23);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[200],
        duration: const Duration(seconds: 1),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Text(
              ' $text ',
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
