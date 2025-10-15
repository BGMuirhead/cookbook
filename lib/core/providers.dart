import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/services/database_service.dart';
import 'package:cookbook_app/features/ingredients/data/repositories/ingredient_repository.dart';
import 'package:cookbook_app/features/recipes/data/repositories/recipe_repository.dart';

// Providers for dependency injection
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) => RecipeRepositoryImpl(ref.read(databaseServiceProvider)));
final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) => IngredientRepositoryImpl(ref.read(databaseServiceProvider)));