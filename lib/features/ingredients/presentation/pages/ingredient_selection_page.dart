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
  final _unitController = TextEditingController();
  GlobalIngredient? _selectedIngredient;

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _unitController.dispose();
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
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Unit (e.g., cups, tsp)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedIngredient != null &&
                    _amountController.text.isNotEmpty &&
                    _unitController.text.isNotEmpty) {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null) {
                    Navigator.pop(context, {
                      'name': _selectedIngredient!.name,
                      'amount': amount,
                      'unit': _unitController.text,
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
              return AlertDialog(
                title: const Text('Add New Ingredient'),
                content: TextField(
                  controller: newIngredientController,
                  decoration: const InputDecoration(labelText: 'Ingredient Name'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final name = newIngredientController.text.trim();
                      if (name.isNotEmpty) {
                        ref.read(ingredientListProvider.notifier).addIngredient(name);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid ingredient name')),
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