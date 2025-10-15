import 'package:cookbook_app/features/recipes/data/models/recipe.dart';

class ScaleRecipe {
  Recipe call(Recipe recipe, double multiplier) {
    return recipe.scale(multiplier);
  }
}