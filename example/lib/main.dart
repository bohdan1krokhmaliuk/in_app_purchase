import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';
import 'package:in_app_purchase/plugin/apple_in_app_purchases.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/bill.dart';
import 'package:in_app_purchase_example/components/coin.dart';
import 'package:in_app_purchase_example/components/purchase_card.dart';
import 'package:in_app_purchase_example/skus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final InAppPurchases purchasesService;

  static const _counterStyle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
  );

  final int coins = 0;
  final int bills = 0;

  List<InAppPurchase> availablePurchases = [];
  StreamSubscription<TransactionDetails>? listener;

  @override
  void initState() {
    super.initState();
    purchasesService = AppleInAppPurchasesImpl();
    purchasesService.initConnection().then((result) {
      final inited = result.valueOrNull ?? false;
      if (mounted && inited) {
        purchasesService.enableLogging(true);
        _fetchAvailablePurchases();
      }
    });
  }

  @override
  void dispose() {
    purchasesService.endConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Awesome purchases')),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$coins', style: _counterStyle),
                  const SizedBox(width: 5.0),
                  const Coin(),
                  const SizedBox(width: 40.0),
                  Text('$bills', style: _counterStyle),
                  const SizedBox(width: 5.0),
                  const Bill(),
                ],
              ),
            ),
            const Divider(thickness: 0.8, indent: 16.0, endIndent: 16.0),
            Expanded(
              child: ListView.builder(
                  itemCount: availablePurchases.length,
                  itemBuilder: (context, index) {
                    final availablePurchase = availablePurchases[index];

                    Widget? icon;

                    if (availablePurchase.sku == Sku.coins.id) {
                      icon = const Coin();
                    } else if (availablePurchase.sku == Sku.money.id) {
                      icon = const Bill();
                    }

                    return PurchaseCard(
                      icon: icon,
                      text: availablePurchase.title,
                      price: availablePurchase.localizedPrice,
                      callback: _startPurchase(availablePurchase),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback _startPurchase(final InAppPurchase product) => () {
        // Another purchase is beeing processed
        if (listener != null) return;
        purchasesService.startPurchase(product);
        listener = purchasesService
            .purchasesDetailsStreamFor(product.sku)
            .listen(handlePurchaseDetails);
      };

  void handlePurchaseDetails(final TransactionDetails details) {
    print(details);
    if (details is PurchaseDetails) {
      purchasesService.finishPurchase(details);
    }
    if (details.state.isFinished) {
      listener?.cancel();
      listener = null;
    }
  }

  Future<void> _fetchAvailablePurchases() async {
    final result = await purchasesService.getInAppPurchases(Sku.values);
    if (result.hasValue && mounted) {
      setState(() => availablePurchases = result.value);
    }
  }
}
