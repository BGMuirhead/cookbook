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
  late FixedExtentScrollController _scrollController;
  double _scaleMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 3); // Start at 1.0 (0.25 * 4)
    _scrollController.addListener(() {
      setState(() {
        _scaleMultiplier = 0.25 + _scrollController.selectedItem * 0.25;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount == amount.floor()) {
      return amount.toStringAsFixed(0);
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipeListProvider);
    final recipe = recipes.firstWhere((r) => r.id == widget.recipeId);
    final scaledRecipe = ScaleRecipe()(recipe, _scaleMultiplier);
    final ingredientList = ref.watch(ingredientListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(scaledRecipe.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servings: ${_formatAmount(scaledRecipe.servings.toDouble())}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Scale Recipe', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(
              height: 100,
              child: RotatedBox(
                quarterTurns: 3, // Rotate to horizontal
                child: ListWheelScrollView(
                  controller: _scrollController,
                  itemExtent: 80, // Width of each item
                  diameterRatio: 2.0, // Curve effect
                  useMagnifier: true,
                  magnification: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  children: List.generate(
                    12, // 0.25 to 3.0
                    (index) => RotatedBox(
                      quarterTurns: 1, // Rotate back for text
                      child: Center(
                        child: Text(
                          'x${_formatAmount(0.25 + index * 0.25)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: (0.25 + index * 0.25) == _scaleMultiplier ? Colors.blue : Colors.black,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            // NEW: Display ingredients in their stored order (no sorting)
            for (var ingredient in scaledRecipe.recipeIngredients)
              Text('• ${_formatAmount(ingredient.amount)} ${ingredient.unit} ${ingredientList.firstWhere((i) => i.id == ingredient.ingredientId).name}'),
            const SizedBox(height: 16),
            Text('Steps', style: Theme.of(context).textTheme.titleMedium),
            for (var step in scaledRecipe.steps) Text('${step.stepOrder}. ${step.description}'),
          ],
        ),
      ),
    );
  }
}