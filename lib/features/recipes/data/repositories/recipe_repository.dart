import 'package:cookbook_app/core/services/database_service.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';

abstract class RecipeRepository {
  Future<int> addRecipe(Recipe recipe);
  Future<List<Recipe>> getAllRecipes();
  Future<List<Recipe>> searchRecipes(String query);
  Future<void> deleteRecipe(int id);
}

class RecipeRepositoryImpl implements RecipeRepository {
  final DatabaseService _databaseService;

  RecipeRepositoryImpl(this._databaseService);

  @override
  Future<int> addRecipe(Recipe recipe) async {
    return await _databaseService.addRecipe(recipe);
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return await _databaseService.getAllRecipes();
  }

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    return await _databaseService.searchRecipes(query);
  }

  @override
  Future<void> deleteRecipe(int id) async {
    await _databaseService.deleteRecipe(id);
  }
}