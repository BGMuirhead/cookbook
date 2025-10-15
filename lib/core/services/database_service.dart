import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cookbook_app/features/ingredients/data/models/global_ingredient.dart';
import 'package:cookbook_app/features/ingredients/data/models/recipe_ingredient.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe.dart';
import 'package:cookbook_app/features/recipes/data/models/recipe_step.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'cookbook.db';
  static const int dbVersion = 1;

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
        price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        servings INTEGER NOT NULL,
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

    // Indexes for performance
    await db.execute('CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id)');
    await db.execute('CREATE INDEX idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id)');
    await db.execute('CREATE INDEX idx_steps_recipe_id ON steps(recipe_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle schema migrations in the future
  }

  // CRUD for GlobalIngredient
  Future<int> addGlobalIngredient(GlobalIngredient ingredient) async {
    final db = await database;
    return await db.insert(
      'global_ingredients',
      ingredient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
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

  // Search by recipe name or ingredient
  Future<List<Recipe>> searchRecipes(String query) async {
    final db = await database;
    final recipeMaps = await db.rawQuery('''
      SELECT DISTINCT r.*
      FROM recipes r
      LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
      LEFT JOIN global_ingredients gi ON ri.ingredient_id = gi.id
      WHERE r.name LIKE ? OR gi.name LIKE ?
    ''', ['%$query%', '%$query%']);
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

  // Delete recipe (cascades to ingredients/steps due to foreign keys)
  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}