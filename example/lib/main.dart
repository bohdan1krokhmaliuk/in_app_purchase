import 'package:flutter/material.dart';
import 'package:in_app_purchase/plugin/apple_in_app_purchases.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/consumables_card.dart';
import 'package:in_app_purchase_example/components/non_consumable_card.dart';
import 'package:in_app_purchase_example/components/non_renewing_card.dart';
import 'package:in_app_purchase_example/components/status_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final InAppPurchases purchasesPlugin;
  bool isPluginInitialized = false;

  @override
  void initState() {
    super.initState();
    purchasesPlugin = AppleInAppPurchasesImpl();
    purchasesPlugin.initConnection().then((result) {
      isPluginInitialized = result.valueOrNull ?? false;
      if (mounted && isPluginInitialized) purchasesPlugin.enableLogging(true);
      setState(() {});
    });
  }

  @override
  void dispose() {
    purchasesPlugin.endConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardInsets = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Awesome purchases')),
        backgroundColor: Colors.grey[100],
        body: ListView(
          children: [
            Padding(
              key: const ValueKey('Status'),
              padding: cardInsets,
              child: StatusCard(isPluginInitialized: isPluginInitialized),
            ),
            Padding(
              key: const ValueKey('Consumables'),
              padding: cardInsets,
              child: ConsumablesCard(purchasesPlugin: purchasesPlugin),
            ),
            Padding(
              key: const ValueKey('Non-Consumables'),
              padding: cardInsets,
              child: NonConsumablesCard(purchasesPlugin: purchasesPlugin),
            ),
            Padding(
              key: const ValueKey('Non-Renewing'),
              padding: cardInsets,
              child: NonRenewingCard(purchasesPlugin: purchasesPlugin),
            ),
          ],
        ),
      ),
    );
  }
}
