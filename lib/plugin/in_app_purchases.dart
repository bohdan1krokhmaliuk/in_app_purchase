import 'package:in_app_purchase/models/base/in_app_purchase.dart';
import 'package:in_app_purchase/models/base/result.dart';
import 'package:in_app_purchase/models/base/transaction_details.dart';

abstract class InAppPurchases<
    I extends InAppPurchase,
    D extends TransactionDetails,
    P extends PurchaseDetails,
    R extends RestoreDetails> {
  Stream<D> get purchasesDetailsStream;
  Stream<D> purchasesDetailsStreamFor(final String sku);

  Future<Result<bool>> initConnection();
  Future<Result<bool>> endConnection();

  Future<Result<bool>> enableLogging(final bool enable);

  Future<Result<List<I>>> getInAppPurchases(
    final List<String> skus,
  );

  Future<Result<List<R>>> getPurchasedProducts();

  Future<Result<bool>> finishPurchase(final P purchase);

  Future<Result<bool>> startPurchase(
    final I purchase, {
    final String? obfuscatedAccountId,
  });
}
