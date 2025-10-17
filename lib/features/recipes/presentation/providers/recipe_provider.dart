import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/providers.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';
import 'package:cookbook_app/features/recipes/data/repositories/recipe_repository.dart';
import 'package:cookbook_app/features/recipes/domain/usecases/add_recipe_with_ingredients.dart';

final recipeListProvider = StateNotifierProvider<RecipeListNotifier, List<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeListNotifier(repository, ref);
});

class RecipeListNotifier extends StateNotifier<List<Recipe>> {
  final RecipeRepository repository;
  final Ref ref;

  RecipeListNotifier(this.repository, this.ref) : super([]) {
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    state = await repository.getAllRecipes();
  }

  Future<void> addRecipe({
    required String name,
    required double servings,
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
    ref.invalidate(searchRecipesProvider); // Invalidate search to refresh
  }

  Future<void> deleteRecipe(int id) async {
    await repository.deleteRecipe(id);
    await fetchRecipes(); // Refresh the list
    ref.invalidate(searchRecipesProvider); // Invalidate search to refresh
  }
}

final searchRecipesProvider = StateNotifierProvider.family<SearchRecipesNotifier, List<Recipe>, String?>((ref, query) {
  final repository = ref.watch(recipeRepositoryProvider);
  return SearchRecipesNotifier(repository, query, ref);
});

class SearchRecipesNotifier extends StateNotifier<List<Recipe>> {
  final RecipeRepository repository;
  final String? query;
  final Ref ref;

  SearchRecipesNotifier(this.repository, this.query, this.ref) : super([]) {
    search();
  }

  Future<void> search() async {
    if (query == null || query!.isEmpty) {
      state = ref.read(recipeListProvider);
    } else {
      state = await repository.searchRecipes(query!);
    }
  }
}