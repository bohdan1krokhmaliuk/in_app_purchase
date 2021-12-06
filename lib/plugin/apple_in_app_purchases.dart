import 'package:flutter/services.dart';
import 'package:in_app_purchase/models/base/result.dart';
import 'package:in_app_purchase/models/ios/apple_in_app_purchase.dart';
import 'package:in_app_purchase/models/ios/apple_payment_offer.dart';
import 'package:in_app_purchase/models/ios/apple_transaction_details.dart';
import 'package:in_app_purchase/plugin/in_app_purchases.dart';

abstract class AppleInAppPurchases
    implements
        InAppPurchases<AppleInAppPurchase, ApplePurchaseDetails,
            AppleRestoreDetails> {
  @override
  Future<Result<bool>> startPurchase(
    final AppleInAppPurchase purchase, {
    final int? quantity,
    final ApplePaymentOffer? offer,
    final String? obfuscatedAccountId,
  });
}

class AppleInAppPurchasesImpl implements AppleInAppPurchases {
  static const MethodChannel _channel = MethodChannel('in_app_purchase');

  @override
  Future<Result<bool>> initConnection({
    final bool enablePendingPurchases = true,
  }) async {
    try {
      final isConnected = await _channel.invokeMethod<bool>('init_connection');
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
  Future<Result<List<AppleInAppPurchase>>> getInAppPurchases(
    final List<String> skus,
  ) async {
    try {
      final inAppPurchasesMap = await _channel.invokeListMethod(
        'get_in_app_purchases',
        {'skus': skus},
      );

      final inAppPurchases = inAppPurchasesMap
          ?.map((json) => AppleInAppPurchase.fromJson(json))
          .toList();

      return Result.success(inAppPurchases ?? []);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<List<AppleRestoreDetails>>> getPurchasedProducts() async {
    try {
      final inAppPurchasesMap = await _channel.invokeListMethod(
        'get_purchased_products',
      );

      final purchasedProducts = inAppPurchasesMap
          ?.map((json) => AppleRestoreDetails.fromJson(json))
          .toList();

      return Result.success(purchasedProducts ?? []);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> startPurchase(
    final AppleInAppPurchase purchase, {
    final int? quantity,
    final ApplePaymentOffer? offer,
    final String? obfuscatedAccountId,
  }) async {
    try {
      await _channel.invokeMethod('start_purchase', <String, dynamic>{
        'sku': purchase.sku,
        'quantity': quantity,
        'user': obfuscatedAccountId,
        if (offer != null) 'offer': offer.toJSON()
      });

      return const Result.success(true);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }

  @override
  Future<Result<bool>> finishPurchase(
    final ApplePurchaseDetails purchase,
  ) async {
    try {
      final isFinished = await _channel.invokeMethod<bool>(
        'finish_transaction',
        <String, dynamic>{'transaction_id': purchase.transactionId},
      );

      return Result.success(isFinished ?? false);
    } on PlatformException catch (exception) {
      return Result.failed(exception);
    }
  }
}
