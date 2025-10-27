import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/features/recipes/presentation/providers/recipe_provider.dart';
import 'package:cookbook_app/features/recipes/presentation/pages/add_recipe_page.dart';
import 'package:cookbook_app/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:cookbook_app/features/recipes/presentation/pages/search_page.dart';
// NEW: Import for edit page
import 'package:cookbook_app/features/recipes/presentation/pages/edit_recipe_page.dart';

class RecipeListPage extends ConsumerWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var recipes = ref.watch(recipeListProvider);
    recipes = List.from(recipes)..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipePage()),
              ).then((_) => ref.read(recipeListProvider.notifier).fetchRecipes());
            },
          ),
        ],
      ),
      body: recipes.isEmpty
          ? const Center(child: Text('No recipes found'))
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Dismissible(
                  key: Key(recipe.id.toString()),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Delete confirmation
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this recipe?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // NEW: Navigate to edit page on swipe left (edit)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRecipePage(recipe: recipe),
                        ),
                      ).then((_) => ref.read(recipeListProvider.notifier).fetchRecipes());
                      return false; // Do not dismiss the item
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      ref.read(recipeListProvider.notifier).deleteRecipe(recipe.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${recipe.name} deleted')),
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(recipe.name),
                    subtitle: Text('Servings: ${recipe.servings} ${recipe.servingName ?? ''}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(recipeId: recipe.id!),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}