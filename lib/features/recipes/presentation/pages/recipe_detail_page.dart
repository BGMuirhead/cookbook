import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/features/ingredients/presentation/providers/ingredient_provider.dart';
import 'package:cookbook_app/features/recipes/domain/usecases/scale_recipe.dart';
import 'package:cookbook_app/features/recipes/presentation/providers/recipe_provider.dart';

class RecipeDetailPage extends ConsumerStatefulWidget {
  final int recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage> {
  double _scaleMultiplier = 1.0;

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipeListProvider);
    final recipe = recipes.firstWhere((r) => r.id == widget.recipeId);
    final scaledRecipe = ScaleRecipe()(recipe, _scaleMultiplier);

    return Scaffold(
      appBar: AppBar(title: Text(scaledRecipe.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servings: ${scaledRecipe.servings} ${scaledRecipe.servingName ?? ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Scale Recipe', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _scaleMultiplier,
              min: 0.5,
              max: 3.0,
              divisions: 25,
              label: _scaleMultiplier.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _scaleMultiplier = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            for (var ingredient in scaledRecipe.recipeIngredients)
              Text('• ${ingredient.amount} ${ingredient.unit} ${ref.watch(ingredientListProvider).firstWhere((i) => i.id == ingredient.ingredientId).name}'),
            const SizedBox(height: 16),
            Text('Steps', style: Theme.of(context).textTheme.titleMedium),
            for (var step in scaledRecipe.steps) Text('${step.stepOrder}. ${step.description}'),
          ],
        ),
      ),
    );
  }
}