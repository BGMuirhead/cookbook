import 'package:cookbook_app/core/services/database_service.dart';
import 'package:cookbook_app/features/ingredients/data/models/global_ingredient.dart';

abstract class IngredientRepository {
  Future<int> addGlobalIngredient(GlobalIngredient ingredient);
  Future<List<GlobalIngredient>> getAllGlobalIngredients();
  Future<GlobalIngredient?> getGlobalIngredientByName(String name);
  Future<GlobalIngredient?> getGlobalIngredientById(int id);
}

class IngredientRepositoryImpl implements IngredientRepository {
  final DatabaseService _databaseService;

  IngredientRepositoryImpl(this._databaseService);

  @override
  Future<int> addGlobalIngredient(GlobalIngredient ingredient) async {
    return await _databaseService.addGlobalIngredient(ingredient);
  }

  @override
  Future<List<GlobalIngredient>> getAllGlobalIngredients() async {
    return await _databaseService.getAllGlobalIngredients();
  }

  @override
  Future<GlobalIngredient?> getGlobalIngredientByName(String name) async {
    return await _databaseService.getGlobalIngredientByName(name);
  }

  @override
  Future<GlobalIngredient?> getGlobalIngredientById(int id) async {
    return await _databaseService.getGlobalIngredientById(id);
  }
}