import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/providers.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';
import 'package:cookbook_app/features/recipes/data/repositories/recipe_repository.dart';
import 'package:cookbook_app/features/recipes/domain/usecases/add_recipe_with_ingredients.dart';

final recipeListProvider = StateNotifierProvider<RecipeListNotifier, List<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeListNotifier(repository);
});

class RecipeListNotifier extends StateNotifier<List<Recipe>> {
  final RecipeRepository repository;

  RecipeListNotifier(this.repository) : super([]) {
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    state = await repository.getAllRecipes();
  }

  Future<void> addRecipe({
    required String name,
    required int servings,
    String? servingName,
    required List<Map<String, dynamic>> ingredients,
    required List<String> steps,
    required AddRecipeWithIngredients addRecipeUseCase,
  }) async {
    await addRecipeUseCase(
      name: name,
      servings: servings,
      servingName: servingName,
      ingredients: ingredients,
      steps: steps,
    );
    await fetchRecipes(); // Refresh the list
  }

  Future<void> deleteRecipe(int id) async {
    await repository.deleteRecipe(id);
    await fetchRecipes(); // Refresh the list
  }
}

final searchRecipesProvider = StateNotifierProvider.family<SearchRecipesNotifier, List<Recipe>, String?>((ref, query) {
  final repository = ref.watch(recipeRepositoryProvider);
  return SearchRecipesNotifier(repository, query);
});

class SearchRecipesNotifier extends StateNotifier<List<Recipe>> {
  final RecipeRepository repository;
  final String? query;

  SearchRecipesNotifier(this.repository, this.query) : super([]) {
    search();
  }

  Future<void> search() async {
    if (query == null || query!.isEmpty) {
      state = await repository.getAllRecipes();
    } else {
      state = await repository.searchRecipes(query!);
    }
  }
}