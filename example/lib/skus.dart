class Sku {
  const Sku._(this.id);

  static const coins = Sku._('com.consumable.coins');
  static const bill = Sku._('com.consumable.bills');

  static const adsFree = Sku._('com.non.consumable.ads.free');
  static const premiumFeature = Sku._('com.non.consumable.premium.feature');

  static List<String> get consumableIdentifiers => [coins.id, bill.id];
  static List<String> get nonConsumableIdentifiers => [
        adsFree.id,
        premiumFeature.id,
      ];

  final String id;
}
