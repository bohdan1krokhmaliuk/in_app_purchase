import 'package:flutter/services.dart';
import 'package:in_app_purchase/models/android/android_enums.dart';
import 'package:in_app_purchase/models/android/google_in_app_purchase.dart';
import 'package:in_app_purchase/models/android/google_purchase_history.dart';
import 'package:in_app_purchase/models/android/google_transaction_details.dart';
import 'package:in_app_purchase/models/base/result.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';

abstract class AndroidInAppPurchases
    implements
        InAppPurchases<GoogleInAppPurchase, GooglePurchaseDetails,
            GoogleRestoreDetails> {
  @override
  Future<Result<bool>> initConnection({
    final bool enablePendingPurchases = true,
  });

  @override
  Future<Result<bool>> startPurchase(
    final GoogleInAppPurchase purchase, {
    final String? obfuscatedAccountId,
    final String? obfuscatedProfileId,
  });

  /// Returns list of in app purchases for [skus] with specified [type] filter
  /// if specified
  @override
  Future<Result<List<GoogleInAppPurchase>>> getInAppPurchases(
    final List<String> skus, {
    final AndroidInAppPurchaseType? type,
  });

  // Android Specific methods

  Future<Result<bool>> consumeAllItems(
    final List<String> skus,
    final AndroidInAppPurchaseType type,
  );

  Future<Result<bool>> updateSubscription(
    final GoogleInAppPurchase newSubscription, {
    required final String oldSubscriptionPurchaseToken,
    final AndroidProrationMode? mode,
    final String? obfuscatedAccountId,
    final String? obfuscatedProfileId,
  });

  Future<Result<List<GooglePurchaseHistoryRecord>>> getPurchaseHistory({
    final AndroidInAppPurchaseType? type,
  });
}

class AndroidInAppPurchasesImpl implements AndroidInAppPurchases {
  static const MethodChannel _channel = MethodChannel('in_app_purchase');

  @override
  Future<Result<bool>> initConnection({
    final bool enablePendingPurchases = true,
  }) async {
    try {
      final isConnected = await _channel.invokeMethod<bool>('init_connection', {
        'enable_pending_purchases': enablePendingPurchases,
      });
      return Result.success(isConnected ?? false);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> endConnection() async {
    try {
      final isEnded = await _channel.invokeMethod<bool>('end_connection');
      return Result.success(isEnded!);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> enableLogging(final bool enable) async {
    try {
      final isEnabled = await _channel.invokeMethod<bool>('enable_logging');
      return Result.success(isEnabled!);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<List<GoogleInAppPurchase>>> getInAppPurchases(
    final List<String> skus, {
    final AndroidInAppPurchaseType? type,
  }) async {
    try {
      final purchases = [];

      if (type != AndroidInAppPurchaseType.subscription) {
        final oneTimeInAppPurchasesMap = await _channel.invokeListMethod(
          'get_in_app_purchases',
          {'skus': skus, 'type': AndroidInAppPurchaseType.oneTime.rawValue},
        );
        purchases.addAll(oneTimeInAppPurchasesMap ?? []);
      }

      if (type != AndroidInAppPurchaseType.oneTime) {
        final subscriptionInAppPurchasesMap = await _channel.invokeListMethod(
          'get_in_app_purchases',
          {
            'skus': skus,
            'type': AndroidInAppPurchaseType.subscription.rawValue
          },
        );
        purchases.addAll(subscriptionInAppPurchasesMap ?? []);
      }

      final inAppPurchases =
          purchases.map((json) => GoogleInAppPurchase.fromJson(json)).toList();

      return Result.success(inAppPurchases);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<List<GoogleRestoreDetails>>> getPurchasedProducts({
    final AndroidInAppPurchaseType? type,
  }) async {
    try {
      final purchasedItems = [];

      if (type != AndroidInAppPurchaseType.subscription) {
        final oneTimePurchasesMap = await _channel.invokeListMethod(
          'get_purchased_products',
          {'type': AndroidInAppPurchaseType.oneTime.rawValue},
        );
        purchasedItems.addAll(oneTimePurchasesMap ?? []);
      }

      if (type != AndroidInAppPurchaseType.oneTime) {
        final subscriptionPurchasesMap = await _channel.invokeListMethod(
          'get_purchased_products',
          {'type': AndroidInAppPurchaseType.subscription.rawValue},
        );
        purchasedItems.addAll(subscriptionPurchasesMap ?? []);
      }

      final purchasedProducts = purchasedItems
          .map((json) => GoogleRestoreDetails.fromJson(json))
          .toList();

      return Result.success(purchasedProducts);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> startPurchase(
    final GoogleInAppPurchase purchase, {
    final String? obfuscatedAccountId,
    final String? obfuscatedProfileId,
  }) async {
    try {
      await _channel.invokeMethod('start_purchase', <String, dynamic>{
        'sku': purchase.sku,
        'obfuscatedAccountId': obfuscatedAccountId,
        'obfuscatedProfileId': obfuscatedProfileId,
      });

      return const Result.success(true);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> finishPurchase(
    final GoogleTransactionDetails purchase, {
    final bool isConsumable = false,
  }) async {
    try {
      if (purchase.isAcknowledged) return const Result.success(true);

      if (isConsumable) {
        final consumedToken = await _channel.invokeMethod<String>(
          'consume_product',
          <String, dynamic>{'token': purchase.purchaseToken},
        );

        return Result.success(consumedToken != null);
      }

      final isAcknowledged = await _channel.invokeMethod<bool>(
        'acknowledge_purchase',
        <String, dynamic>{'token': purchase.purchaseToken},
      );

      return Result.success(isAcknowledged ?? false);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  Future<Result<List<GoogleInAppPurchase>>> getInAppPurchasesByType(
    final List<String> skus,
    final AndroidInAppPurchaseType type,
  ) async {
    try {
      final inAppPurchasesMap = await _channel.invokeListMethod(
        'get_in_app_purchases',
        {'skus': skus, 'type': type.rawValue},
      );

      final inAppPurchases = inAppPurchasesMap
          ?.map((json) => GoogleInAppPurchase.fromJson(json))
          .toList();

      return Result.success(inAppPurchases ?? []);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> consumeAllItems(
    final List<String> skus,
    final AndroidInAppPurchaseType type,
  ) async {
    try {
      await _channel.invokeMethod('consume_all_products');

      return const Result.success(true);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> updateSubscription(
    GoogleInAppPurchase newSubscription, {
    required String oldSubscriptionPurchaseToken,
    AndroidProrationMode? mode,
    String? obfuscatedAccountId,
    String? obfuscatedProfileId,
  }) async {
    try {
      await _channel.invokeMethod('start_purchase', <String, dynamic>{
        'sku': newSubscription.sku,
        'prorationMode': mode?.rawValue,
        'obfuscatedAccountId': obfuscatedAccountId,
        'obfuscatedProfileId': obfuscatedProfileId,
        'purchaseToken': oldSubscriptionPurchaseToken,
      });

      return const Result.success(true);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<List<GooglePurchaseHistoryRecord>>> getPurchaseHistory({
    AndroidInAppPurchaseType? type,
  }) async {
    try {
      final history = [];

      if (type != AndroidInAppPurchaseType.subscription) {
        final oneTimePurchasesMap = await _channel.invokeListMethod(
          'get_purchase_history',
          {'type': AndroidInAppPurchaseType.oneTime.rawValue},
        );
        history.addAll(oneTimePurchasesMap ?? []);
      }

      if (type != AndroidInAppPurchaseType.oneTime) {
        final subscriptionPurchasesMap = await _channel.invokeListMethod(
          'get_purchase_history',
          {'type': AndroidInAppPurchaseType.subscription.rawValue},
        );
        history.addAll(subscriptionPurchasesMap ?? []);
      }

      final purchasedProducts = history
          .map((json) => GooglePurchaseHistoryRecord.fromJson(json))
          .toList();

      return Result.success(purchasedProducts);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }
}
