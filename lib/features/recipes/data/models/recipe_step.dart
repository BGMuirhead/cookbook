class RecipeStep {
  final int? id;
  final int recipeId;
  final int order;
  final String description;

  RecipeStep({
    this.id,
    required this.recipeId,
    required this.order,
    required this.description,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: map['id'],
      recipeId: map['recipe_id'],
      order: map['order'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'recipe_id': recipeId,
        'order': order,
        'description': description,
      };

  Map<String, dynamic> toJson() => {
        'order': order,
        'description': description,
      };
}