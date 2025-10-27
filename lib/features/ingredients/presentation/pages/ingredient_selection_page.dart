import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/features/ingredients/data/models/global_ingredient.dart';
import 'package:cookbook_app/features/ingredients/presentation/providers/ingredient_provider.dart';

class IngredientSelectionPage extends ConsumerStatefulWidget {
  const IngredientSelectionPage({super.key});

  @override
  ConsumerState<IngredientSelectionPage> createState() => _IngredientSelectionPageState();
}

class _IngredientSelectionPageState extends ConsumerState<IngredientSelectionPage> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  GlobalIngredient? _selectedIngredient;

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientListProvider);
    var filteredIngredients = ingredients.where((ingredient) {
      return ingredient.name.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
    filteredIngredients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Select Ingredient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredIngredients.isEmpty
                  ? const Center(child: Text('No ingredients found'))
                  : ListView.builder(
                      itemCount: filteredIngredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = filteredIngredients[index];
                        return ListTile(
                          title: Text(ingredient.name),
                          subtitle: Text('Unit: ${ingredient.defaultUnit}'),
                          onTap: () {
                            setState(() {
                              _selectedIngredient = ingredient;
                            });
                          },
                          selected: _selectedIngredient == ingredient,
                          selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _selectedIngredient != null
                    ? 'Unit: ${_selectedIngredient!.defaultUnit}'
                    : 'Select an ingredient to see unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedIngredient != null && _amountController.text.isNotEmpty) {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null) {
                    Navigator.pop(context, {
                      'name': _selectedIngredient!.name,
                      'amount': amount,
                      'unit': _selectedIngredient!.defaultUnit,
                      'ingredient_id': _selectedIngredient!.id,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an ingredient and fill all fields')),
                  );
                }
              },
              child: const Text('Add Ingredient'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}