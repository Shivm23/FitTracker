import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/recipe_dbo.dart';

class RecipesDataSource {
  final log = Logger('RecipesDataSource');
  final Box<RecipesDBO> _recipesBox;

  RecipesDataSource(this._recipesBox);

  /// Ajouter une recette complète
  Future<void> addRecipe(RecipesDBO recipe) async {
    log.fine('Adding new recipe to db');
    await _recipesBox.put(
        recipe.recipe.code ?? recipe.recipe.name ?? "", recipe);
  }

  /// Ajouter plusieurs recettes
  Future<void> addAllRecipes(List<RecipesDBO> recipes) async {
    log.fine('Adding multiple recipes to db');
    final Map<String, RecipesDBO> entries = {
      for (var r in recipes) (r.recipe.code ?? r.recipe.name ?? ""): r
    };
    await _recipesBox.putAll(entries);
  }

  /// Supprimer une recette à partir de son code ou nom
  Future<void> deleteRecipe(String key) async {
    log.fine('Deleting recipe with key $key');
    await _recipesBox.delete(key);
  }

  /// Mettre à jour une recette (remplace tout l'objet)
  Future<void> updateRecipe(String key, RecipesDBO updatedRecipe) async {
    log.fine('Updating recipe with key $key');
    await _recipesBox.put(key, updatedRecipe);
  }

  /// Obtenir une recette à partir de son code ou nom
  Future<RecipesDBO?> getRecipeByKey(String key) async {
    return _recipesBox.get(key);
  }

  /// Obtenir toutes les recettes
  Future<List<RecipesDBO>> getAllRecipes() async {
    return _recipesBox.values.toList();
  }

  /// Rechercher une recette par nom (contains)
  Future<List<RecipesDBO>> searchRecipes(String query) async {
    final lowerQuery = query.toLowerCase();
    return _recipesBox.values
        .where((recipe) =>
            recipe.recipe.name?.toLowerCase().contains(lowerQuery) ?? false)
        .toList();
  }
}
