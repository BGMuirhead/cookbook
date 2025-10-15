import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookbook_app/core/providers.dart';
import 'package:cookbook_app/features/ingredients/data/models/global_ingredient.dart';
import 'package:cookbook_app/features/ingredients/data/repositories/ingredient_repository.dart';

final ingredientListProvider = StateNotifierProvider<IngredientListNotifier, List<GlobalIngredient>>((ref) {
  final repository = ref.watch(ingredientRepositoryProvider);
  return IngredientListNotifier(repository);
});

class IngredientListNotifier extends StateNotifier<List<GlobalIngredient>> {
  final IngredientRepository repository;

  IngredientListNotifier(this.repository) : super([]) {
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    state = await repository.getAllGlobalIngredients();
  }

  Future<void> addIngredient(String name) async {
    await repository.addGlobalIngredient(GlobalIngredient(name: name));
    await fetchIngredients(); // Refresh the list
  }
}