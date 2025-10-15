class GlobalIngredient {
  final int? id;
  final String name;
  final double? purchaseAmount;
  final String? purchaseUnit;
  final double? price;

  GlobalIngredient({
    this.id,
    required this.name,
    this.purchaseAmount,
    this.purchaseUnit,
    this.price,
  });

  factory GlobalIngredient.fromMap(Map<String, dynamic> map) {
    return GlobalIngredient(
      id: map['id'],
      name: map['name'],
      purchaseAmount: map['purchase_amount'],
      purchaseUnit: map['purchase_unit'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'purchase_amount': purchaseAmount,
        'purchase_unit': purchaseUnit,
        'price': price,
      };

  double? get costPerUnit => price != null && purchaseAmount != null ? price! / purchaseAmount! : null;
}