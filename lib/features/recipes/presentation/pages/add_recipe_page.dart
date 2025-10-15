import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/providers.dart';
import 'package:cookbook_app/features/ingredients/presentation/widgets/ingredient_selector.dart';
import 'package:cookbook_app/features/recipes/domain/usecases/add_recipe_with_ingredients.dart';
import 'package:cookbook_app/features/recipes/presentation/providers/recipe_provider.dart';

class AddRecipePage extends ConsumerStatefulWidget {
  const AddRecipePage({super.key});

  @override
  ConsumerState<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends ConsumerState<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingsController = TextEditingController();
  final _servingNameController = TextEditingController();
  final List<Map<String, dynamic>> _ingredients = [];
  final List<String> _steps = [];
  final _stepController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    _servingNameController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _addIngredient(Map<String, dynamic> ingredient) {
    setState(() {
      _ingredients.add(ingredient);
    });
  }

  void _addStep() {
    if (_stepController.text.isNotEmpty) {
      setState(() {
        _steps.add(_stepController.text);
        _stepController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (value) => value!.isEmpty ? 'Enter a recipe name' : null,
              ),
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Servings'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Enter a valid number' : null,
              ),
              TextFormField(
                controller: _servingNameController,
                decoration: const InputDecoration(labelText: 'Serving Name (e.g., portions)'),
              ),
              const SizedBox(height: 16),
              const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IngredientSelector(onIngredientAdded: _addIngredient),
              for (var ingredient in _ingredients)
                ListTile(
                  title: Text('${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _ingredients.remove(ingredient);
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16),
              const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _stepController,
                decoration: const InputDecoration(labelText: 'Add Step'),
                onFieldSubmitted: (_) => _addStep(),
              ),
              for (var i = 0; i < _steps.length; i++)
                ListTile(
                  title: Text('${i + 1}. ${_steps[i]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _steps.removeAt(i);
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final addRecipeUseCase = AddRecipeWithIngredients(
                        ref.read(recipeRepositoryProvider),
                        ref.read(ingredientRepositoryProvider),
                      );
                      await ref.read(recipeListProvider.notifier).addRecipe(
                            name: _nameController.text,
                            servings: int.parse(_servingsController.text),
                            servingName: _servingNameController.text.isEmpty ? null : _servingNameController.text,
                            ingredients: _ingredients,
                            steps: _steps,
                            addRecipeUseCase: addRecipeUseCase,
                          );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding recipe: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}