import 'package:cookbook_app/features/ingredients/data/models/global_ingredient.dart';
import 'package:cookbook_app/features/ingredients/data/models/recipe_ingredient.dart';
import 'package:cookbook_app/features/ingredients/data/repositories/ingredient_repository.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe_step.dart';
import 'package:cookbook_app/features/recipes/data/repositories/recipe_repository.dart';

class AddRecipeWithIngredients {
  final RecipeRepository recipeRepository;
  final IngredientRepository ingredientRepository;

  AddRecipeWithIngredients(this.recipeRepository, this.ingredientRepository);

  Future<int> call({
    required String name,
    required int servings,
    String? servingName,
    required List<Map<String, dynamic>> ingredients,
    required List<String> steps,
  }) async {
    final now = DateTime.now();
    final recipeIngredients = <RecipeIngredient>[];
    final recipeSteps = <RecipeStep>[];

    // Ensure all ingredients exist in global_ingredients
    for (var ingredientData in ingredients) {
      final name = ingredientData['name'] as String;
      var globalIngredient = await ingredientRepository.getGlobalIngredientByName(name);
      if (globalIngredient == null) {
        globalIngredient = GlobalIngredient(name: name);
        final id = await ingredientRepository.addGlobalIngredient(globalIngredient);
        globalIngredient = GlobalIngredient(id: id, name: name);
      }
      recipeIngredients.add(RecipeIngredient(
        recipeId: 0, // Will be set after recipe insertion
        ingredientId: globalIngredient.id!,
        amount: ingredientData['amount'] as double,
        unit: ingredientData['unit'] as String,
      ));
    }

    // Create steps
    for (var i = 0; i < steps.length; i++) {
      recipeSteps.add(RecipeStep(
        recipeId: 0, // Will be set after recipe insertion
        stepOrder: i + 1,
        description: steps[i],
      ));
    }

    // Create recipe
    final recipe = Recipe(
      name: name,
      servings: servings,
      servingName: servingName,
      createdAt: now,
      updatedAt: now,
      recipeIngredients: recipeIngredients,
      steps: recipeSteps,
    );

    return await recipeRepository.addRecipe(recipe);
  }
}