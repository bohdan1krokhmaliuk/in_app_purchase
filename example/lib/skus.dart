class Sku {
  const Sku._(this.id);

  static const coins = Sku._('com.consumable.coins');
  static const money = Sku._('com.consumable.bills');

  static List<String> get values => [coins.id, money.id];

  final String id;
}
