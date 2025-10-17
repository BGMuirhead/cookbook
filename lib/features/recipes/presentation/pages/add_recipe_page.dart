import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/providers.dart';
import 'package:cookbook_app/features/ingredients/presentation/pages/ingredient_selection_page.dart';
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
  bool _isLoading = false;

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
      _ingredients.sort((a, b) => a['name'].compareTo(b['name']));
    });
  }

  void _addStep() {
    final stepText = _stepController.text.trim();
    if (stepText.isNotEmpty) {
      setState(() {
        _steps.add(stepText);
        _stepController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Step cannot be empty or just spaces')),
      );
    }
  }

  void _editStep(int index) {
    final editController = TextEditingController(text: _steps[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Step'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Step Description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final editedText = editController.text.trim();
              if (editedText.isNotEmpty) {
                setState(() {
                  _steps[index] = editedText;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Step cannot be empty or just spaces')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showPreviewDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Recipe Preview'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${_nameController.text}', style: Theme.of(context).textTheme.titleMedium),
                  Text('Servings: ${_servingsController.text} ${_servingNameController.text.isEmpty ? '' : _servingNameController.text}'),
                  const SizedBox(height: 8),
                  const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var ingredient in _ingredients)
                    Text('• ${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}'),
                  const SizedBox(height: 8),
                  const Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var i = 0; i < _steps.length; i++) Text('${i + 1}. ${_steps[i]}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty || _steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one ingredient and one step')),
        );
        return;
      }
      final confirmed = await _showPreviewDialog();
      if (!confirmed) return;
      setState(() {
        _isLoading = true;
      });
      try {
        final addRecipeUseCase = AddRecipeWithIngredients(
          ref.read(recipeRepositoryProvider),
          ref.read(ingredientRepositoryProvider),
        );
        await ref.read(recipeListProvider.notifier).addRecipe(
              name: _nameController.text,
              servings: double.parse(_servingsController.text),
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      validator: (value) {
                        if (value!.isEmpty) return 'Enter a valid number';
                        final parsed = double.tryParse(value);
                        if (parsed == null) return 'Enter a valid number';
                        if (parsed != parsed.floor()) return 'Enter a whole number';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _servingNameController,
                      decoration: const InputDecoration(labelText: 'Serving Name (e.g., portions)'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IngredientSelectionPage()),
                        );
                        if (result != null) {
                          _addIngredient(result);
                        }
                      },
                      child: const Text('Add Ingredient'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    for (var i = 0; i < _steps.length; i++)
                      ListTile(
                        title: Text('${i + 1}. ${_steps[i]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editStep(i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _steps.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: _stepController,
                      decoration: const InputDecoration(labelText: 'Add Step'),
                      onFieldSubmitted: (_) => _addStep(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveRecipe,
                      child: const Text('Save Recipe'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}