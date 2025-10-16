class RecipeIngredient {
  final int? id;
  final int recipeId;
  final int ingredientId;
  final double amount;
  final String unit;

  RecipeIngredient({
    this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.amount,
    required this.unit,
  });

  // Scaling: Handle units intelligently
  RecipeIngredient scale(double multiplier) {
    double newAmount = amount * multiplier;
    if (unit == 'each') {
      newAmount = newAmount.roundToDouble();
    } else {
      // Round to 2 decimal places for other units
      newAmount = double.parse(newAmount.toStringAsFixed(2));
    }
    return RecipeIngredient(
      id: id,
      recipeId: recipeId,
      ingredientId: ingredientId,
      amount: newAmount,
      unit: unit,
    );
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id'],
      recipeId: map['recipe_id'],
      ingredientId: map['ingredient_id'],
      amount: map['amount'],
      unit: map['unit'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'recipe_id': recipeId,
        'ingredient_id': ingredientId,
        'amount': amount,
        'unit': unit,
      };

  Map<String, dynamic> toJson() => {
        'ingredient_id': ingredientId,
        'amount': amount,
        'unit': unit,
      };
}