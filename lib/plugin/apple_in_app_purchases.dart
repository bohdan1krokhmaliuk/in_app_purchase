import 'package:flutter/services.dart';
import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/purchase_details.dart';
import 'package:in_app_purchase/models/base/result.dart';
import 'package:in_app_purchase/models/ios/apple_in_app_purchase.dart';
import 'package:in_app_purchase/models/ios/apple_purchase_details.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';

class AppleInAppPurchases implements InAppPurchases {
  static const MethodChannel _channel = MethodChannel('in_app_purchase');

  @override
  Future<Result<bool>> initConnection({
    final bool enablePendingPurchases = true,
  }) async {
    try {
      final isConnected = await _channel.invokeMethod<bool>('init_connection');
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
  Future<Result<bool>> enableLogging(bool enable) async {
    try {
      final isEnabled = await _channel.invokeMethod<bool>('enable_logging');
      return Result.success(isEnabled!);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<List<AppleInAppPurchase>>> getInAppPurchases(
    List<String> skus,
  ) async {
    try {
      final inAppPurchasesMap = await _channel.invokeListMethod(
        'get_in_app_purchases',
        {'skus': skus},
      );

      final inAppPurchases = inAppPurchasesMap
          ?.map((json) => AppleInAppPurchase.fromJSON(json))
          .toList();

      return Result.success(inAppPurchases ?? []);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<List<PurchaseDetails>>> getPurchasedProducts() async {
    try {
      final inAppPurchasesMap = await _channel.invokeListMethod(
        'get_purchased_products',
      );

      final purchasedProducts = inAppPurchasesMap
          ?.map((json) => ApplePurchaseDetails.fromJson(json))
          .toList();

      return Result.success(purchasedProducts ?? []);
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
}
