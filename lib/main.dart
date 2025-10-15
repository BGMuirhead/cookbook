import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/services/database_service.dart';
import 'package:cookbook_app/features/ingredients/data/repositories/ingredient_repository.dart';
import 'package:cookbook_app/features/recipes/data/repositories/recipe_repository.dart';
import 'package:cookbook_app/features/recipes/domain/usecases/add_recipe_with_ingredients.dart';

// Providers for dependency injection
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) => RecipeRepositoryImpl(ref.read(databaseServiceProvider)));
final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) => IngredientRepositoryImpl(ref.read(databaseServiceProvider)));

void main() {
  runApp(const ProviderScope(child: CookbookApp()));
}

class CookbookApp extends StatelessWidget {
  const CookbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookbook App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cookbook App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Cookbook App!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  print('Starting data layer test...');
                  final recipeRepo = ref.read(recipeRepositoryProvider);
                  final ingredientRepo = ref.read(ingredientRepositoryProvider);

                  // Add a sample recipe
                  print('Adding sample recipe...');
                  final addRecipeUseCase = AddRecipeWithIngredients(recipeRepo, ingredientRepo);
                  final recipeId = await addRecipeUseCase(
                    name: 'Test Recipe',
                    servings: 4,
                    servingName: 'portions',
                    ingredients: [
                      {'name': 'Flour', 'amount': 2.0, 'unit': 'cups'},
                      {'name': 'Sugar', 'amount': 1.0, 'unit': 'cup'},
                    ],
                    steps: ['Mix ingredients', 'Bake at 350°F'],
                  );
                  print('Recipe added with ID: $recipeId');

                  // Fetch and print all recipes
                  print('Fetching all recipes...');
                  final recipes = await recipeRepo.getAllRecipes();
                  print('Recipes: ${recipes.map((r) => r.toJson()).toList()}');
                } catch (e, stackTrace) {
                  print('Error during data layer test: $e');
                  print('Stack trace: $stackTrace');
                }
              },
              child: const Text('Test Data Layer'),
            ),
          ],
        ),
      ),
    );
  }
}