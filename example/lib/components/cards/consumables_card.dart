import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/cards/card_base.dart';
import 'package:in_app_purchase_example/components/mixin/snack_bar_mixin.dart';
import 'package:in_app_purchase_example/components/product_component.dart';
import 'package:in_app_purchase_example/components/icons/sku_icon.dart';
import 'package:in_app_purchase_example/skus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsumablesCard extends StatefulWidget {
  const ConsumablesCard({Key? key, required final this.purchasesPlugin})
      : super(key: key);

  final InAppPurchases purchasesPlugin;

  @override
  State<ConsumablesCard> createState() => _ConsumablesCardState();
}

class _ConsumablesCardState extends State<ConsumablesCard> with SnackBarMixin {
  List<InAppPurchase> availableProducts = [];
  StreamSubscription<TransactionDetails>? listener;

  bool isInitialized = false;
  final values = <String, int>{};

  static const _titleStyle = TextStyle(
    fontSize: 18.0,
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );

  static const _counterStyle = TextStyle(
    fontSize: 28.0,
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
      height: 307,
      child: isInitialized
          ? Column(
              children: [
                const Text('Consumables', style: _titleStyle),
                const Divider(thickness: 0.7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: Sku.consumableIdentifiers
                      .map<List<Widget>>(
                        (sku) => [
                          Text('${values[sku]}', style: _counterStyle),
                          const SizedBox(width: 5.0),
                          SkuIcon(sku: sku, dimension: 25),
                        ],
                      )
                      .expand((widgets) => widgets)
                      .toList()
                    ..insert(3, const SizedBox(width: 40.0)),
                ),
                ...Sku.consumableIdentifiers
                    .map<Widget>(
                      (sku) => TextButton(
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              Text('Spend ${_skuName(sku)}'),
                            ],
                          ),
                        ),
                        onPressed: () => _spend(sku),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          primary: Colors.white,
                        ),
                      ),
                    )
                    .toList(),
                const Divider(thickness: 0.7),
                ...availableProducts.map<ProductComponent>(
                  (p) => ProductComponent(
                    text: p.title,
                    icon: SkuIcon(sku: p.sku),
                    callback: _startPurchase(p),
                    price: availableProducts.first.localizedPrice,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _initialize() async {
    await _initializeBalance();
    await _fetchAvailablePurchases();
    if (mounted) setState(() => isInitialized = true);
  }

  Future<void> _initializeBalance() async {
    final storage = await SharedPreferences.getInstance();
    for (final sku in Sku.consumableIdentifiers) {
      values[sku] = storage.getInt(sku) ?? 0;
    }
  }

  Future<void> _fetchAvailablePurchases() async {
    final result = await widget.purchasesPlugin.getInAppPurchases(
      Sku.consumableIdentifiers,
    );
    if (result.hasValue) availableProducts = result.value;
  }

  VoidCallback _startPurchase(final InAppPurchase product) => () {
        // Another purchase is beeing processed
        if (listener != null) return;
        widget.purchasesPlugin.startPurchase(product);
        listener = widget.purchasesPlugin
            .purchasesDetailsStreamFor(product.sku)
            .listen(_handlePurchaseDetails);
      };

  Future<void> _handlePurchaseDetails(final TransactionDetails details) async {
    if (details is PurchaseDetails) {
      await _handleSuccessfulPurchase(details.sku);
      widget.purchasesPlugin.finishPurchase(details);
    }
    if (details.state.isFinished) {
      listener?.cancel();
      listener = null;
    }
  }

  /// [IOS] Consumables are not managed by storekit so make sure that
  /// you handle consumables on your side.
  Future<void> _handleSuccessfulPurchase(final String sku) async {
    final currentAmount = values[sku];
    if (currentAmount == null) return;

    final totalAmount = currentAmount + _purchasedAmount(sku);
    final storage = await SharedPreferences.getInstance();
    await storage.setInt(sku, totalAmount);
    values[sku] = totalAmount;

    if (mounted) setState(() {});
  }

  Future<void> _spend(final String sku) async {
    final currentAmount = values[sku];

    if (currentAmount == null) return;
    if (currentAmount <= 0) return _showNoConsumableSnackbar(sku, context);

    final totalAmount = currentAmount - 1;
    final storage = await SharedPreferences.getInstance();
    await storage.setInt(sku, totalAmount);
    values[sku] = totalAmount;

    if (mounted) setState(() {});
  }

  int _purchasedAmount(final String sku) {
    if (sku == Sku.bill.id) {
      return 30;
    } else if (sku == Sku.coins.id) {
      return 20;
    }

    return 0;
  }

  String _skuName(final String sku) {
    if (sku == Sku.bill.id) {
      return 'Bill';
    } else if (sku == Sku.coins.id) {
      return 'Coin';
    }

    return '';
  }

  void _showNoConsumableSnackbar(
    final String sku,
    final BuildContext context,
  ) async {
    final icon = SkuIcon(sku: sku, dimension: 23);
    showSnackbar('Buy more', color: Colors.red, icon: icon);
  }
}
