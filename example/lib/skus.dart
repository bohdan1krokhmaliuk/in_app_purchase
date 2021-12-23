class Sku {
  const Sku._(this.id);

  static const coins = Sku._('com.consumable.coins');
  static const bill = Sku._('com.consumable.bills');

  static List<String> get consumableIdentifiers => [coins.id, bill.id];

  final String id;
}
