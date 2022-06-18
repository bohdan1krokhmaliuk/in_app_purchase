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

class NonRenewingCard extends StatefulWidget {
  const NonRenewingCard({Key? key, required final this.purchasesPlugin})
      : super(key: key);

  final InAppPurchases purchasesPlugin;

  @override
  State<NonRenewingCard> createState() => _NonRenewingCardState();
}

class _NonRenewingCardState extends State<NonRenewingCard> with SnackBarMixin {
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
    return CardBase(
      height: 261,
      child: isInitialized
          ? Column(
              children: [
                const Text('Non-Renewing Subscriptions', style: _titleStyle),
                const Divider(thickness: 0.7),
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
                  onPressed: () => _simulateMonthPassed(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    primary: Colors.white,
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Simulate month passed',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Divider(thickness: 0.7),
                ...availableProducts.map<ProductComponent>(
                  (p) => ProductComponent(
                    text: p.title,
                    icon: Sku.hasIcon(p.sku) ? SkuIcon(sku: p.sku) : null,
                    callback: _startPurchase(p, context),
                    price: _hasActiveSubscription(p.sku)
                        ? 'Extend ${p.localizedPrice}'
                        : p.localizedPrice,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
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
        showSnackbar('$actionText ${skuName(sku)}');
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

  Future<void> _simulateMonthPassed(final BuildContext context) async {
    final storage = await SharedPreferences.getInstance();

    final finishedSkus = <String>[];
    for (final sku in subscriptionDurations.keys) {
      final currentDuration = subscriptionDurations[sku];
      if (currentDuration != null && currentDuration > 0) {
        final reducedDuration = currentDuration - 1;
        subscriptionDurations[sku] = reducedDuration;
        await storage.setInt(sku, reducedDuration);

        if (reducedDuration == 0) finishedSkus.add(sku);
      }
    }

    if (mounted) setState(() {});
    showSnackbar('Month passed');

    for (final sku in finishedSkus) {
      showSnackbar(
        '${skuName(sku)} subscription finished',
        color: Colors.orange,
      );
    }
  }

  String skuName(final String sku) {
    if (sku == Sku.basicSub.id) {
      return 'Basic';
    } else if (sku == Sku.premiumSub.id) {
      return 'Premium';
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
