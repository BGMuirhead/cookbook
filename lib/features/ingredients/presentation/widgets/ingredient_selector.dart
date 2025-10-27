import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/features/ingredients/presentation/providers/ingredient_provider.dart';

class IngredientSelector extends ConsumerWidget {
  const IngredientSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            final newIngredientController = TextEditingController();
            final defaultUnitController = TextEditingController();
            return AlertDialog(
              title: const Text('Add New Ingredient'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newIngredientController,
                    decoration: const InputDecoration(labelText: 'Ingredient Name'),
                  ),
                  TextField(
                    controller: defaultUnitController,
                    decoration: const InputDecoration(labelText: 'Default Unit (e.g., grams)'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final name = newIngredientController.text.trim();
                    final defaultUnit = defaultUnitController.text.trim();
                    if (name.isNotEmpty && defaultUnit.isNotEmpty) {
                      // FIX: Added defaultUnit parameter
                      ref.read(ingredientListProvider.notifier).addIngredient(
                            name,
                            defaultUnit: defaultUnit,
                          );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid ingredient name and default unit')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}