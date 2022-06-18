class Sku {
  const Sku._(this.id);

  // Consumables
  static const coins = Sku._('com.consumable.coins');
  static const bill = Sku._('com.consumable.bills');

  static List<String> get consumableIdentifiers => [coins.id, bill.id];

  // Non-renewing subscriptions
  static const basicSub = Sku._('com.non.renewing.basic');
  static const premiumSub = Sku._('com.non.renewing.premium');

  static List<String> get nonRenewingIdentifiers => [
        basicSub.id,
        premiumSub.id,
      ];

  // Non-consumables
  static const adsFree = Sku._('com.non.consumable.ads.free');
  static const premiumFeature = Sku._('com.non.consumable.premium.feature');

  static List<String> get nonConsumableIdentifiers => [
        adsFree.id,
        premiumFeature.id,
      ];

  // Subscriptions
  static const basicMonthly = Sku._('com.auto.renewable.basic.monthly');
  static const basicYearly = Sku._('com.auto.renewable.basic.yearly');
  static const basicPlusYearly = Sku._('com.auto.renewable.basic.plus.yearly');
  static const basicPlusPlusYearly =
      Sku._('com.auto.renewable.basic.plus.plus.yearly');
  static const premiumQuaterly = Sku._('com.auto.renewable.premium.quaterly');
  static const premiumYearly = Sku._('com.auto.renewable.premium.yearly');

  static List<String> get subscriptonsIdentifiers => [
        ...basicSubscriptonsIdentifiers,
        ...premiumSubscriptonsIdentifiers,
      ];
  static List<String> get basicSubscriptonsIdentifiers => [
        basicMonthly.id,
        basicYearly.id,
        basicPlusYearly.id,
        basicPlusPlusYearly.id,
      ];
  static List<String> get premiumSubscriptonsIdentifiers => [
        premiumQuaterly.id,
        premiumYearly.id,
      ];

  static bool hasIcon(final String sku) =>
      [coins.id, bill.id, adsFree.id, premiumFeature.id].contains(sku);

  final String id;
}
