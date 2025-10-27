import 'package:cookbook_app/features/ingredients/data/models/global_ingredient.dart';
import 'package:cookbook_app/features/ingredients/data/models/recipe_ingredient.dart';
import 'package:cookbook_app/features/ingredients/data/repositories/ingredient_repository.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe_step.dart';
import 'package:cookbook_app/features/recipes/data/repositories/recipe_repository.dart';

class UpdateRecipeWithIngredients {
  final RecipeRepository recipeRepository;
  final IngredientRepository ingredientRepository;

  UpdateRecipeWithIngredients(this.recipeRepository, this.ingredientRepository);

  Future<void> call({
    required int id,
    required String name,
    required double servings,
    String? servingName,
    required DateTime createdAt,
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
        globalIngredient = GlobalIngredient(
          name: name,
          defaultUnit: ingredientData['unit'] as String, // FIX: Added defaultUnit
        );
        final newId = await ingredientRepository.addGlobalIngredient(globalIngredient);
        globalIngredient = globalIngredient.copyWith(id: newId);
      }
      recipeIngredients.add(RecipeIngredient(
        recipeId: id, // Use existing recipe ID
        ingredientId: globalIngredient.id!,
        amount: ingredientData['amount'] as double,
        unit: ingredientData['unit'] as String,
      ));
    }

    // Create steps
    for (var i = 0; i < steps.length; i++) {
      recipeSteps.add(RecipeStep(
        recipeId: id, // Use existing recipe ID
        stepOrder: i + 1,
        description: steps[i],
      ));
    }

    // Create updated recipe object
    final recipe = Recipe(
      id: id,
      name: name,
      servings: servings,
      servingName: servingName,
      createdAt: createdAt,
      updatedAt: now,
      recipeIngredients: recipeIngredients,
      steps: recipeSteps,
    );

    await recipeRepository.updateRecipe(recipe);
  }
}