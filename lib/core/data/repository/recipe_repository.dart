import 'package:opennutritracker/core/domain/entity/recipe_entity.dart';
import 'package:opennutritracker/core/data/data_source/recipe_data_source.dart';
import 'package:opennutritracker/core/data/dbo/recipe_dbo.dart';

class RecipeRepository {
  final RecipesDataSource _dataSource;

  RecipeRepository(this._dataSource);

  /// Ajouter une recette
  Future<void> addRecipe(RecipeEntity recipeEntity) async {
    final dbo = RecipesDBO.fromRecipeEntity(recipeEntity);
    await _dataSource.addRecipe(dbo);
  }

  /// Supprimer une recette par son code ou nom
  Future<void> deleteRecipe(String key) async {
    await _dataSource.deleteRecipe(key);
  }

  /// Mettre à jour une recette
  Future<void> updateRecipe(String key, RecipeEntity recipeEntity) async {
    final updatedDbo = RecipesDBO.fromRecipeEntity(recipeEntity);
    await _dataSource.updateRecipe(key, updatedDbo);
  }

  /// Récupérer une recette par sa clé (code ou nom)
  Future<RecipeEntity?> getRecipeByKey(String key) async {
    final dbo = await _dataSource.getRecipeByKey(key);
    return dbo?.toEntity();
  }

  /// Récupérer toutes les recettes
  Future<List<RecipeEntity>> getAllRecipes() async {
    final list = await _dataSource.getAllRecipes();
    return list.map((r) => r.toEntity()).toList();
  }

  /// Rechercher des recettes par texte
  Future<List<RecipeEntity>> searchRecipes(String query) async {
    final results = await _dataSource.searchRecipes(query);
    return results.map((r) => r.toEntity()).toList();
  }
}
