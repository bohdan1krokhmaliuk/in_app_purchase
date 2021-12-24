import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/transaction_details.dart';
import 'package:in_app_purchase/models/base/transaction_state.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';
import 'package:in_app_purchase_example/components/product_component.dart';
import 'package:in_app_purchase_example/components/sku_icon.dart';
import 'package:in_app_purchase_example/skus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NonRenewingCard extends StatefulWidget {
  const NonRenewingCard({Key? key, required final this.purchasesPlugin})
      : super(key: key);

  final InAppPurchases purchasesPlugin;

  @override
  State<NonRenewingCard> createState() => _NonRenewingCardState();
}

class _NonRenewingCardState extends State<NonRenewingCard> {
  List<InAppPurchase> availableProducts = [];
  StreamSubscription<TransactionDetails>? listener;

  bool isInitialized = false;
  final subscriptionDurations = <String, int>{};

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
        height: 295,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: isInitialized
            ? Column(
                children: [
                  const Text('Non-Renewing Subscriptions', style: _titleStyle),
                  const SizedBox(height: 20),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: Sku.nonRenewingIdentifiers
                        .map<Widget>(
                          (sku) => _SubscriptionStatus(
                            name: skuName(sku),
                            duration: '${subscriptionDurations[sku]}m',
                          ),
                        )
                        .toList()
                      ..insert(1, const SizedBox(width: 20.0)),
                  ),
                  const SizedBox(height: 5),
                  TextButton(
                    onPressed: () => _simulateMonthSpent(context),
                    child: const Text('Spend month'),
                  ),
                  const Divider(thickness: 1.0, indent: 16.0, endIndent: 16.0),
                  ...availableProducts.map<ProductComponent>(
                    (p) => ProductComponent(
                      text: p.title,
                      icon: SkuIcon(sku: p.sku),
                      callback: _startPurchase(p, context),
                      price: _hasActiveSubscription(p.sku)
                          ? 'Extend ${p.localizedPrice}'
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
    await _initializeSubscriptionsCapacity();
    if (mounted) setState(() => isInitialized = true);
  }

  Future<void> _initializeSubscriptionsCapacity() async {
    final storage = await SharedPreferences.getInstance();

    for (final sku in Sku.nonRenewingIdentifiers) {
      subscriptionDurations[sku] = storage.getInt(sku) ?? 0;
    }
  }

  Future<void> _fetchAvailablePurchases() async {
    final available = await widget.purchasesPlugin.getInAppPurchases(
      Sku.nonRenewingIdentifiers,
    );
    if (available.hasValue) availableProducts = available.value;
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
    final storage = await SharedPreferences.getInstance();
    if (details is PurchaseDetails) {
      widget.purchasesPlugin.finishPurchase(details);
      final sku = details.sku;
      final currentDuration = subscriptionDurations[sku];

      if (currentDuration != null) {
        final extendedDuration = currentDuration + 1;
        subscriptionDurations[sku] = extendedDuration;
        await storage.setInt(sku, extendedDuration);

        final actionText = currentDuration > 0 ? 'Extended' : 'Subscribed for';
        _showSnackbar('$actionText ${skuName(sku)}', context);
      }

      setState(() {});
    }

    if (details.state.isFinished) {
      listener?.cancel();
      listener = null;
    }
  }

  bool _hasActiveSubscription(final String sku) {
    final currentDuration = subscriptionDurations[sku];
    return currentDuration != null && currentDuration > 0;
  }

  Future<void> _simulateMonthSpent(final BuildContext context) async {
    final storage = await SharedPreferences.getInstance();

    for (final sku in subscriptionDurations.keys) {
      final currentDuration = subscriptionDurations[sku];
      if (currentDuration != null && currentDuration > 0) {
        final reducedDuration = currentDuration - 1;
        subscriptionDurations[sku] = reducedDuration;
        await storage.setInt(sku, reducedDuration);

        if (reducedDuration == 0) {
          _showSnackbar(
            '${skuName(sku)} subscription finished',
            context,
            color: Colors.red[200],
          );
        }
      }
    }

    if (mounted) setState(() {});
    _showSnackbar('Month spent', context);
  }

  void _showSnackbar(
    final String text,
    final BuildContext context, {
    final Widget? icon,
    final Color? color,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color ?? Colors.green[200],
        duration: const Duration(seconds: 1),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon,
            Flexible(
              child: Text(
                ' $text ',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            if (icon != null) icon,
          ],
        ),
      ),
    );
  }

  String skuName(final String sku) {
    if (sku == Sku.premiumSub.id) {
      return 'Premium';
    } else if (sku == Sku.premiumPlusSub.id) {
      return 'Premium+';
    }

    return '';
  }
}

class _SubscriptionStatus extends StatelessWidget {
  const _SubscriptionStatus({
    Key? key,
    required this.duration,
    required this.name,
  }) : super(key: key);

  static const _durationStyle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
  );

  final String duration;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text(duration, style: _durationStyle),
        const SizedBox(width: 5.0),
        Text(name),
      ],
    );
  }
}
