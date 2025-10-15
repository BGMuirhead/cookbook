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
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitController = TextEditingController();
  String? _selectedIngredient;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientListProvider);

    return Column(
      children: [
        DropdownButton<String>(
          hint: const Text('Select or type ingredient'),
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
              _nameController.text = value ?? '';
            });
          },
        ),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Ingredient Name'),
          onChanged: (value) {
            setState(() {
              _selectedIngredient = null;
            });
          },
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
            if (_nameController.text.isNotEmpty && _amountController.text.isNotEmpty && _unitController.text.isNotEmpty) {
              final amount = double.tryParse(_amountController.text);
              if (amount != null) {
                widget.onIngredientAdded({
                  'name': _nameController.text,
                  'amount': amount,
                  'unit': _unitController.text,
                });
                ref.read(ingredientListProvider.notifier).addIngredient(_nameController.text);
                _nameController.clear();
                _amountController.clear();
                _unitController.clear();
                _selectedIngredient = null;
              }
            }
          },
          child: const Text('Add Ingredient'),
        ),
      ],
    );
  }
}