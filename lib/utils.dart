import 'modules.dart';

List<InAppPurchase> extractItems(List<dynamic> result) {
  List<InAppPurchase> products = result
      .map<InAppPurchase>(
          (map) => InAppPurchase.fromJSON(Map<String, dynamic>.from(map)))
      .toList();

  return products;
}

List<PurchasedItem> extractPurchased(List<dynamic> result) {
  final purhcased = result
      .map<PurchasedItem>(
        (product) => PurchasedItem.fromJSON(Map<String, dynamic>.from(product)),
      )
      .toList();

  return purhcased;
}

class EnumUtil {
  /// return enum value
  ///
  /// example: enum Type {Hoge},
  /// String value = EnumUtil.getValueString(Type.Hoge);
  /// assert(value == "Hoge");
  static String getValueString(dynamic enumType) =>
      enumType.toString().split('.')[1];
}
