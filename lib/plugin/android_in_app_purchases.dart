import 'package:flutter/services.dart';
import 'package:in_app_purchase/models/android/google_in_app_purchase.dart';
import 'package:in_app_purchase/models/android/google_purchase_details.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/purchase_details.dart';
import 'package:in_app_purchase/models/base/result.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';

class AndroidInAppPurchases extends InAppPurchases {
  static const MethodChannel _channel = MethodChannel('in_app_purchase');

  @override
  Future<Result<bool>> initConnection({
    final bool enablePendingPurchases = true,
  }) async {
    try {
      final isConnected = await _channel.invokeMethod<bool>('init_connection', {
        'enable_pending_purchases': enablePendingPurchases,
      });
      return Result.success(isConnected!);
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
    final List<String> skus,
  ) async {
    try {
      final oneTimeInAppPurchasesMap = await _channel.invokeListMethod(
        'get_in_app_purchases',
        {'skus': skus, 'type': AndroidInAppPurchaseType.oneTime.rawValue},
      );

      final subscriptionInAppPurchasesMap = await _channel.invokeListMethod(
        'get_in_app_purchases',
        {'skus': skus, 'type': AndroidInAppPurchaseType.subscription.rawValue},
      );

      final inAppPurchases = [
        ...?oneTimeInAppPurchasesMap,
        ...?subscriptionInAppPurchasesMap
      ].map((json) => GoogleInAppPurchase.fromJson(json)).toList();

      return Result.success(inAppPurchases);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<List<GooglePurchaseDetails>>> getPurchasedProducts() async {
    try {
      final oneTimePurchasesMap = await _channel.invokeListMethod(
        'get_purchased_products',
        {'type': AndroidInAppPurchaseType.oneTime.rawValue},
      );

      final subscriptionPurchasesMap = await _channel.invokeListMethod(
        'get_purchased_products',
        {'type': AndroidInAppPurchaseType.subscription.rawValue},
      );

      final purchasedProducts = [
        ...?oneTimePurchasesMap,
        ...?subscriptionPurchasesMap
      ].map((json) => GooglePurchaseDetails.fromJson(json)).toList();

      return Result.success(purchasedProducts);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> startPurchase(
    InAppPurchase purchase, {
    String? obfuscatedAccountId,
  }) {
    // TODO: implement startPurchase
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> finishPurchase(PurchaseDetails purchase) {
    // TODO: implement finishPurchase
    throw UnimplementedError();
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

  Future<Result<List<GooglePurchaseDetails>>> getPurchasedProductsByType(
    final List<String> skus,
    final AndroidInAppPurchaseType type,
  ) async {
    try {
      final inAppPurchasesMap = await _channel.invokeListMethod(
        'get_purchased_products',
        {'type': type.rawValue},
      );

      final purchasedProducts = inAppPurchasesMap
          ?.map((json) => GooglePurchaseDetails.fromJson(json))
          .toList();

      return Result.success(purchasedProducts ?? []);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }
}

enum AndroidInAppPurchaseType { subscription, oneTime }

extension AndroidInAppPurchaseTypeExt on AndroidInAppPurchaseType {
  String get rawValue {
    switch (this) {
      case AndroidInAppPurchaseType.subscription:
        return 'subs';
      case AndroidInAppPurchaseType.oneTime:
        return 'inapp';
    }
  }
}