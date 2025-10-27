import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cookbook_app/features/ingredients/data/models/global_ingredient.dart';
import 'package:cookbook_app/features/ingredients/data/models/recipe_ingredient.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe_step.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'cookbook.db';
  static const int dbVersion = 1; // Incremented to force DB rebuild

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE global_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        purchase_amount REAL,
        purchase_unit TEXT,
        price REAL,
        default_unit TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        servings REAL NOT NULL,
        serving_name TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        ingredient_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES global_ingredients(id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        step_order INTEGER NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id)');
    await db.execute('CREATE INDEX idx_steps_recipe_id ON steps(recipe_id)');

    // Pre-populate common ingredients
    await db.transaction((txn) async {
      final commonIngredients = [
        {'name': 'Plain Flour', 'default_unit': 'g'},
        {'name': 'Wholemeal Flour', 'default_unit': 'g'},
        {'name': 'White Sugar', 'default_unit': 'g'},
        {'name': 'Raw Sugar', 'default_unit': 'g'},
        {'name': 'Brown Sugar', 'default_unit': 'g'},
        {'name': 'Dark Brown Sugar', 'default_unit': 'g'},
        {'name': 'Salted Butter', 'default_unit': 'g'},
        {'name': 'Unsalted Butter', 'default_unit': 'g'},
        {'name': 'Eggs', 'default_unit': 'units'},
        {'name': 'Milk', 'default_unit': 'ml'},
        {'name': 'Salt', 'default_unit': 'g'},
        {'name': 'Yeast', 'default_unit': 'g'},
        {'name': 'Baking Powder', 'default_unit': 'g'},
        {'name': 'Baking Soda', 'default_unit': 'g'},
        {'name': 'Cinnamon', 'default_unit': 'g'},
        {'name': 'Nutmeg', 'default_unit': 'g'},
        {'name': 'Vanilla Extract', 'default_unit': 'ml'},
        {'name': 'Vegetable Oil', 'default_unit': 'ml'}
      ];

      for (var ingredient in commonIngredients) {
        try {
          await txn.insert('global_ingredients', ingredient);
        } catch (e) {
          // Log error but continue to avoid stopping the transaction
          print('Error inserting ingredient ${ingredient['name']}: $e');
        }
      }
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // No migration needed since we're rebuilding from scratch
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE global_ingredients ADD COLUMN default_unit TEXT NOT NULL DEFAULT "grams"');
    }
    // Future migrations can be added here if needed
  }

  // CRUD for GlobalIngredient
  Future<int> addGlobalIngredient(GlobalIngredient ingredient) async {
    final db = await database;
    return await db.insert('global_ingredients', ingredient.toMap());
  }

  Future<List<GlobalIngredient>> getAllGlobalIngredients() async {
    final db = await database;
    final maps = await db.query('global_ingredients');
    return maps.map((map) => GlobalIngredient.fromMap(map)).toList();
  }

  Future<GlobalIngredient?> getGlobalIngredientByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'global_ingredients',
      where: 'name = ?',
      whereArgs: [name],
    );
    return maps.isNotEmpty ? GlobalIngredient.fromMap(maps.first) : null;
  }

  Future<GlobalIngredient?> getGlobalIngredientById(int id) async {
    final db = await database;
    final maps = await db.query(
      'global_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? GlobalIngredient.fromMap(maps.first) : null;
  }

  // CRUD for Recipe
  Future<int> addRecipe(Recipe recipe) async {
    final db = await database;
    return await db.transaction((txn) async {
      final recipeId = await txn.insert('recipes', recipe.toMap());
      for (var ingredient in recipe.recipeIngredients) {
        await txn.insert('recipe_ingredients', {
          ...ingredient.toMap(),
          'recipe_id': recipeId,
        });
      }
      for (var step in recipe.steps) {
        await txn.insert('steps', {
          ...step.toMap(),
          'recipe_id': recipeId,
        });
      }
      return recipeId;
    });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'recipes',
        recipe.toMap(),
        where: 'id = ?',
        whereArgs: [recipe.id],
      );
      // Delete existing related records
      await txn.delete('recipe_ingredients', where: 'recipe_id = ?', whereArgs: [recipe.id]);
      await txn.delete('steps', where: 'recipe_id = ?', whereArgs: [recipe.id]);
      // Insert new related records
      for (var ingredient in recipe.recipeIngredients) {
        await txn.insert('recipe_ingredients', {
          ...ingredient.toMap(),
          'recipe_id': recipe.id,
        });
      }
      for (var step in recipe.steps) {
        await txn.insert('steps', {
          ...step.toMap(),
          'recipe_id': recipe.id,
        });
      }
    });
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final recipeMaps = await db.query('recipes');
    final List<Recipe> recipes = [];
    for (var map in recipeMaps) {
      final ingredients = await db.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [map['id']],
      );
      final steps = await db.query(
        'steps',
        where: 'recipe_id = ?',
        whereArgs: [map['id']],
        orderBy: 'step_order ASC',
      );
      recipes.add(Recipe.fromMap(
        map,
        ingredients.map((i) => RecipeIngredient.fromMap(i)).toList(),
        steps.map((s) => RecipeStep.fromMap(s)).toList(),
      ));
    }
    return recipes;
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final db = await database;
    final recipeMaps = await db.rawQuery('''
      SELECT DISTINCT r.*
      FROM recipes r
      WHERE r.name LIKE ?
    ''', ['%$query%']);
    final List<Recipe> recipes = [];
    for (var map in recipeMaps) {
      final ingredients = await db.query(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [map['id']],
      );
      final steps = await db.query(
        'steps',
        where: 'recipe_id = ?',
        whereArgs: [map['id']],
        orderBy: 'step_order ASC',
      );
      recipes.add(Recipe.fromMap(
        map,
        ingredients.map((i) => RecipeIngredient.fromMap(i)).toList(),
        steps.map((s) => RecipeStep.fromMap(s)).toList(),
      ));
    }
    return recipes;
  }

  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}