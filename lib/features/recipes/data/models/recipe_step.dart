class RecipeStep {
  final int? id;
  final int recipeId;
  final int stepOrder;
  final String description;

  RecipeStep({
    this.id,
    required this.recipeId,
    required this.stepOrder,
    required this.description,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: map['id'],
      recipeId: map['recipe_id'],
      stepOrder: map['step_order'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'recipe_id': recipeId,
        'step_order': stepOrder,
        'description': description,
      };

  Map<String, dynamic> toJson() => {
        'step_order': stepOrder,
        'description': description,
      };
}