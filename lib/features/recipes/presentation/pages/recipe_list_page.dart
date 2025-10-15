import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/features/recipes/presentation/providers/recipe_provider.dart';
import 'package:cookbook_app/features/recipes/presentation/pages/add_recipe_page.dart';
import 'package:cookbook_app/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:cookbook_app/features/recipes/presentation/pages/search_page.dart';

class RecipeListPage extends ConsumerStatefulWidget {
  const RecipeListPage({super.key});

  @override
  ConsumerState<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends ConsumerState<RecipeListPage> {
  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookbook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipePage()),
              );
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
                return ListTile(
                  title: Text(recipe.name),
                  subtitle: Text('Servings: ${recipe.servings} ${recipe.servingName ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await ref.read(recipeListProvider.notifier).deleteRecipe(recipe.id!);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipeId: recipe.id!),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}