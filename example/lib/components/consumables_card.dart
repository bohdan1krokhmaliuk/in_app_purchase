import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/bill.dart';
import 'package:in_app_purchase_example/components/coin.dart';
import 'package:in_app_purchase_example/components/purchase_card.dart';
import 'package:in_app_purchase_example/components/sku_icon.dart';
import 'package:in_app_purchase_example/skus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsumablesCard extends StatefulWidget {
  const ConsumablesCard({Key? key, required final this.purchasesPlugin})
      : super(key: key);

  final InAppPurchases purchasesPlugin;

  @override
  State<ConsumablesCard> createState() => _ConsumablesCardState();
}

class _ConsumablesCardState extends State<ConsumablesCard> {
  List<InAppPurchase> availablePurchases = [];
  StreamSubscription<TransactionDetails>? listener;

  bool isInitialized = false;
  int coins = 0;
  int bills = 0;

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
    return Card(
      elevation: 8,
      child: Container(
        height: 262,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: isInitialized
            ? Column(
                children: [
                  const Text('Consumables', style: _titleStyle),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$coins', style: _counterStyle),
                      const SizedBox(width: 5.0),
                      GestureDetector(
                        child: const Coin(),
                        onTap: () => _spend(Sku.coins.id, context),
                      ),
                      const SizedBox(width: 40.0),
                      Text('$bills', style: _counterStyle),
                      const SizedBox(width: 5.0),
                      GestureDetector(
                        child: const Bill(),
                        onTap: () => _spend(Sku.bill.id, context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1.0, indent: 16.0, endIndent: 16.0),
                  PurchaseCard(
                    text: availablePurchases.first.title,
                    price: availablePurchases.first.localizedPrice,
                    icon: SkuIcon(sku: availablePurchases.first.sku),
                    callback: _startPurchase(availablePurchases.first),
                  ),
                  PurchaseCard(
                    text: availablePurchases.last.title,
                    price: availablePurchases.last.localizedPrice,
                    icon: SkuIcon(sku: availablePurchases.last.sku),
                    callback: _startPurchase(availablePurchases.last),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _initialize() async {
    await _initializeBalance();
    await _fetchAvailablePurchases();
    if (mounted) setState(() => isInitialized = true);
  }

  Future<void> _initializeBalance() async {
    final storage = await SharedPreferences.getInstance();
    bills = storage.getInt(Sku.bill.id) ?? 0;
    coins = storage.getInt(Sku.coins.id) ?? 0;
  }

  Future<void> _fetchAvailablePurchases() async {
    final result = await widget.purchasesPlugin.getInAppPurchases(
      Sku.consumableIdentifiers,
    );
    if (result.hasValue) availablePurchases = result.value;
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

  Future<void> _handleSuccessfulPurchase(final String sku) async {
    final storage = await SharedPreferences.getInstance();
    if (sku == Sku.bill.id) {
      bills += 30;
      await storage.setInt(Sku.bill.id, bills);
    } else if (sku == Sku.coins.id) {
      coins += 20;
      await storage.setInt(Sku.coins.id, coins);
    }

    if (mounted) setState(() {});
  }

  Future<void> _spend(final String sku, final BuildContext context) async {
    final storage = await SharedPreferences.getInstance();
    if (sku == Sku.bill.id) {
      if (bills <= 0) {
        return _showEmptyConsumableSnackbar(sku, context);
      }
      bills--;
      await storage.setInt(Sku.bill.id, bills);
    } else if (sku == Sku.coins.id) {
      if (coins <= 0) {
        return _showEmptyConsumableSnackbar(sku, context);
      }
      coins--;
      await storage.setInt(Sku.coins.id, coins);
    }

    if (mounted) setState(() {});
  }

  void _showEmptyConsumableSnackbar(
    final String sku,
    final BuildContext context,
  ) async {
    final icon = SkuIcon(sku: sku, dimension: 23);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const Text(' Buy more ', style: TextStyle(fontSize: 20)),
            icon,
          ],
        ),
      ),
    );
  }
}
