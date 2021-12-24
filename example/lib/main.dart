import 'package:flutter/material.dart';
import 'package:in_app_purchase/plugin/apple_in_app_purchases.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/cards/consumables_card.dart';
import 'package:in_app_purchase_example/components/cards/non_consumable_card.dart';
import 'package:in_app_purchase_example/components/cards/non_renewing_card.dart';
import 'package:in_app_purchase_example/components/cards/status_card.dart';

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
    const divider = SizedBox(height: 6.0);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Awesome purchases')),
        backgroundColor: Colors.grey[100],
        body: Builder(builder: (context) {
          final padding =
              const EdgeInsets.all(8.0) + MediaQuery.of(context).viewPadding;
          return ListView(
            padding: padding,
            children: [
              StatusCard(isPluginInitialized: isPluginInitialized),
              if (isPluginInitialized) ...[
                divider,
                ConsumablesCard(purchasesPlugin: purchasesPlugin),
                divider,
                NonConsumablesCard(purchasesPlugin: purchasesPlugin),
                divider,
                NonRenewingCard(purchasesPlugin: purchasesPlugin),
              ]
            ],
          );
        }),
      ),
    );
  }
}
