import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/providers.dart';
import 'package:cookbook_app/features/ingredients/presentation/pages/ingredient_selection_page.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';
import 'package:cookbook_app/features/recipes/domain/usecases/update_recipe_with_ingredients.dart';
import 'package:cookbook_app/features/recipes/presentation/providers/recipe_provider.dart';

class EditRecipePage extends ConsumerStatefulWidget {
  final Recipe recipe;

  const EditRecipePage({super.key, required this.recipe});

  @override
  ConsumerState<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends ConsumerState<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingsController = TextEditingController();
  final _servingNameController = TextEditingController();
  final List<Map<String, dynamic>> _ingredients = [];
  List<String> _steps = [];
  final _stepController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.recipe.name;
    _servingsController.text = widget.recipe.servings.toStringAsFixed(0);
    _servingNameController.text = widget.recipe.servingName ?? '';
    _steps = widget.recipe.steps.map((s) => s.description).toList();
    Future.microtask(_loadIngredients);
  }

  Future<void> _loadIngredients() async {
    final ingredientRepo = ref.read(ingredientRepositoryProvider);
    final List<Map<String, dynamic>> loadedIngredients = [];
    for (var ri in widget.recipe.recipeIngredients) {
      final gi = await ingredientRepo.getGlobalIngredientById(ri.ingredientId);
      if (gi != null) {
        loadedIngredients.add({
          'name': gi.name,
          'amount': ri.amount,
          'unit': gi.defaultUnit,
          'ingredient_id': gi.id,
        });
      }
    }
    setState(() {
      _ingredients.addAll(loadedIngredients);
    });
  }

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

  void _editIngredient(int index) {
    final ingredient = _ingredients[index];
    final _editAmountController = TextEditingController(text: ingredient['amount'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Name: ${ingredient['name']}'),
            TextField(
              controller: _editAmountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            Text('Unit: ${ingredient['unit']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newAmount = double.tryParse(_editAmountController.text);
              if (newAmount != null) {
                setState(() {
                  _ingredients[index]['amount'] = newAmount;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
              Text('Servings: ${_servingsController.text} ${_servingNameController.text}'),
              const SizedBox(height: 16),
              const Text('Ingredients:'),
              for (var ingredient in _ingredients)
                Text('• ${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}'),
              const SizedBox(height: 16),
              const Text('Steps:'),
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
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      final confirm = await _showPreviewDialog();
      if (confirm) {
        setState(() {
          _isLoading = true;
        });
        try {
          final servings = double.parse(_servingsController.text);
          final updateRecipeUseCase = UpdateRecipeWithIngredients(
            ref.read(recipeRepositoryProvider),
            ref.read(ingredientRepositoryProvider),
          );
          await updateRecipeUseCase(
            id: widget.recipe.id!,
            name: _nameController.text,
            servings: servings,
            servingName: _servingNameController.text.isEmpty ? null : _servingNameController.text,
            createdAt: widget.recipe.createdAt,
            ingredients: _ingredients,
            steps: _steps,
          );
          if (mounted) {
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving recipe: $e')),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Recipe')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Recipe Name'),
                      validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                    ),
                    TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(labelText: 'Servings (whole number)'),
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
                    for (var i = 0; i < _ingredients.length; i++)
                      ListTile(
                        title: Text('${_ingredients[i]['amount']} ${_ingredients[i]['unit']} ${_ingredients[i]['name']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editIngredient(i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _ingredients.removeAt(i);
                                });
                              },
                            ),
                          ],
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
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}