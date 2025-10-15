import 'package:cookbook_app/features/ingredients/data/models/recipe_ingredient.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe_step.dart';

class Recipe {
  final int? id;
  final String name;
  final int servings;
  final String? servingName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RecipeIngredient> recipeIngredients;
  final List<RecipeStep> steps;

  Recipe({
    this.id,
    required this.name,
    required this.servings,
    this.servingName,
    required this.createdAt,
    required this.updatedAt,
    required this.recipeIngredients,
    required this.steps,
  });

  // Scaling logic: Returns a new Recipe with scaled ingredients
  Recipe scale(double multiplier) {
    return Recipe(
      id: id,
      name: name,
      servings: (servings * multiplier).round(),
      servingName: servingName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      recipeIngredients: recipeIngredients.map((ri) => ri.scale(multiplier)).toList(),
      steps: steps,
    );
  }

  // From DB map (for queries)
  factory Recipe.fromMap(Map<String, dynamic> map, List<RecipeIngredient> ingredients, List<RecipeStep> steps) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      servings: map['servings'],
      servingName: map['serving_name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      recipeIngredients: ingredients,
      steps: steps,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'servings': servings,
        'serving_name': servingName,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  // JSON for export
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'servings': servings,
        'serving_name': servingName,
        'recipe_ingredients': recipeIngredients.map((ri) => ri.toJson()).toList(),
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}