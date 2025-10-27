class GlobalIngredient {
  final int? id;
  final String name;
  final double? purchaseAmount;
  final String? purchaseUnit;
  final double? price;
  final String defaultUnit; // NEW: Added defaultUnit

  GlobalIngredient({
    this.id,
    required this.name,
    this.purchaseAmount,
    this.purchaseUnit,
    this.price,
    required this.defaultUnit, // NEW: Required
  });

  factory GlobalIngredient.fromMap(Map<String, dynamic> map) {
    return GlobalIngredient(
      id: map['id'],
      name: map['name'],
      purchaseAmount: map['purchase_amount'],
      purchaseUnit: map['purchase_unit'],
      price: map['price'],
      defaultUnit: map['default_unit'] ?? 'grams', // NEW: Fallback for migration
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'purchase_amount': purchaseAmount,
        'purchase_unit': purchaseUnit,
        'price': price,
        'default_unit': defaultUnit, // NEW
      };

  double? get costPerUnit => price != null && purchaseAmount != null ? price! / purchaseAmount! : null;

  GlobalIngredient copyWith({
    int? id,
    String? name,
    double? purchaseAmount,
    String? purchaseUnit,
    double? price,
    String? defaultUnit, // NEW
  }) {
    return GlobalIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      price: price ?? this.price,
      defaultUnit: defaultUnit ?? this.defaultUnit, // NEW
    );
  }
}