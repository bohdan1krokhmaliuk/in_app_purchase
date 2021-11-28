import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/purchase_details.dart';
import 'package:in_app_purchase/models/base/result.dart';

abstract class InAppPurchases {
  Future<Result<bool>> initConnection();
  Future<Result<bool>> endConnection();

  Future<Result<bool>> enableLogging(final bool enable);

  Future<Result<List<InAppPurchase>>> getInAppPurchases(
    final List<String> skus,
  );

  Future<Result<List<PurchaseDetails>>> getPurchasedProducts();

  Future<Result<bool>> finishPurchase(final PurchaseDetails purchase);

  Future<Result<bool>> startPurchase(
    final InAppPurchase purchase, {
    final String? obfuscatedAccountId,
  });
}
