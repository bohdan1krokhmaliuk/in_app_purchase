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

class SubscriptionsCard extends StatefulWidget {
  const SubscriptionsCard({Key? key, required final this.purchasesPlugin})
      : super(key: key);

  final InAppPurchases purchasesPlugin;

  @override
  State<SubscriptionsCard> createState() => _SubscriptionsCardState();
}

class _SubscriptionsCardState extends State<SubscriptionsCard>
    with SnackBarMixin {
  StreamSubscription<TransactionDetails>? listener;
  List<PurchaseDetails> purchasedSubscriptions = [];
  List<InAppPurchase> availableBasicSubscriptions = [];
  List<InAppPurchase> availablePremiumSubscriptions = [];
  List<InAppPurchase> get availableSubscriptions => [
        ...availableBasicSubscriptions,
        ...availablePremiumSubscriptions,
      ];

  bool get hasBasicSubscriptons => availableBasicSubscriptions.isNotEmpty;
  bool get hasPremiumSubscriptons => availablePremiumSubscriptions.isNotEmpty;

  bool isInitialized = false;
  bool isRefreshing = false;

  static const _headingStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

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
      height: 463,
      child: isInitialized
          ? Column(
              children: [
                const Text('Subscriptions', style: _titleStyle),
                const SizedBox(height: 5.0),
                const Divider(thickness: 0.7),
                TextButton(
                  onPressed: isRefreshing ? null : _refresh,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    primary: Colors.white,
                  ),
                  child: SizedBox(
                    height: 28.0,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isRefreshing
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Refresh subscription status'),
                      ],
                    ),
                  ),
                ),
                const Divider(thickness: 0.7),
                if (hasBasicSubscriptons)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Basic subscriptions group',
                      style: _headingStyle,
                    ),
                  ),
                if (hasBasicSubscriptons)
                  ...availableBasicSubscriptions.map<ProductComponent>(
                    (p) {
                      final isSubscribed = _isProductPurchased(p.sku);
                      return ProductComponent(
                        text: p.title,
                        callback: _startPurchase(p, context),
                        price: isSubscribed ? 'Subscribed' : p.localizedPrice,
                        icon: Sku.hasIcon(p.sku) ? SkuIcon(sku: p.sku) : null,
                        buttonColor: isSubscribed ? Colors.grey : Colors.green,
                      );
                    },
                  ),
                const Divider(thickness: 0.7),
                if (hasPremiumSubscriptons)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Premium subscriptions group',
                      style: _headingStyle,
                    ),
                  ),
                if (hasPremiumSubscriptons)
                  ...availablePremiumSubscriptions.map<ProductComponent>(
                    (p) {
                      final isSubscribed = _isProductPurchased(p.sku);
                      return ProductComponent(
                        text: p.title,
                        callback: _startPurchase(p, context),
                        price: isSubscribed ? 'Subscribed' : p.localizedPrice,
                        icon: Sku.hasIcon(p.sku) ? SkuIcon(sku: p.sku) : null,
                        buttonColor: isSubscribed ? Colors.grey : Colors.green,
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

  Future<void> _refresh() async {
    if (mounted) setState(() => isRefreshing = true);
    await _fetchAvailablePurchases();
    if (mounted) setState(() => isRefreshing = false);
  }

  Future<void> _fetchAvailablePurchases() async {
    final available = await widget.purchasesPlugin.getInAppPurchases(
      Sku.subscriptonsIdentifiers,
    );

    if (available.hasValue) {
      final subscriptions = available.value;

      availableBasicSubscriptions = _filterSubscriptions(
        subscriptions,
        Sku.basicSubscriptonsIdentifiers,
      );
      availablePremiumSubscriptions = _filterSubscriptions(
        subscriptions,
        Sku.premiumSubscriptonsIdentifiers,
      );
    }

    final purchased = await widget.purchasesPlugin.getPurchasedProducts();
    if (available.hasValue) {
      purchasedSubscriptions.clear();
      purchasedSubscriptions.addAll(purchased.value.where(
        (details) => availableSubscriptions.any(
          (product) => details.sku == product.sku,
        ),
      ));
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
      if (!purchasedSubscriptions.any(
        (product) => product.sku == details.sku,
      )) {
        purchasedSubscriptions.add(details);
        _showSnackbar(details.sku, 'Purchased');
        setState(() {});
        _refresh();
      } else {
        _showSnackbar(details.sku, 'Already subscribed');
      }
    }

    if (details.state.isFinished) {
      listener?.cancel();
      listener = null;
    }
  }

  bool _isProductPurchased(final String sku) {
    return purchasedSubscriptions.any((p) => p.sku == sku);
  }

  void _showSnackbar(final String sku, final String text) async {
    final icon = SkuIcon(sku: sku, dimension: 23);
    showSnackbar(text, icon: icon);
  }

  List<InAppPurchase> _filterSubscriptions(
    final List<InAppPurchase> available,
    final List<String> skus,
  ) {
    return available.where((sub) => skus.any((sku) => sub.sku == sku)).toList();
  }
}
