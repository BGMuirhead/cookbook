import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/features/ingredients/presentation/providers/ingredient_provider.dart';

class IngredientSelector extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onIngredientAdded;

  const IngredientSelector({super.key, required this.onIngredientAdded});

  @override
  ConsumerState<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends ConsumerState<IngredientSelector> {
  final _amountController = TextEditingController();
  final _unitController = TextEditingController();
  final _newIngredientController = TextEditingController();
  String? _selectedIngredient;

  @override
  void dispose() {
    _amountController.dispose();
    _unitController.dispose();
    _newIngredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientListProvider);

    return Column(
      children: [
        DropdownButton<String>(
          hint: const Text('Select ingredient'),
          value: _selectedIngredient,
          isExpanded: true,
          items: ingredients
              .map((ingredient) => DropdownMenuItem(
                    value: ingredient.name,
                    child: Text(ingredient.name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedIngredient = value;
            });
          },
        ),
        if (_selectedIngredient == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: _newIngredientController,
              decoration: const InputDecoration(labelText: 'New Ingredient Name'),
            ),
          ),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: _unitController,
          decoration: const InputDecoration(labelText: 'Unit (e.g., cups, tsp)'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final name = _selectedIngredient ?? _newIngredientController.text;
            if (name.isNotEmpty && _amountController.text.isNotEmpty && _unitController.text.isNotEmpty) {
              final amount = double.tryParse(_amountController.text);
              if (amount != null) {
                widget.onIngredientAdded({
                  'name': name,
                  'amount': amount,
                  'unit': _unitController.text,
                });
                if (_selectedIngredient == null) {
                  ref.read(ingredientListProvider.notifier).addIngredient(name);
                }
                _amountController.clear();
                _unitController.clear();
                _newIngredientController.clear();
                setState(() {
                  _selectedIngredient = null;
                });
              }
            }
          },
          child: const Text('Add Ingredient'),
        ),
      ],
    );
  }
}