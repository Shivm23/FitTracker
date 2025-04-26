import 'package:opennutritracker/core/data/repository/recipe_repository.dart';

class DeleteRecipeUsecase {
  final RecipeRepository _recipeRepository;

  DeleteRecipeUsecase(this._recipeRepository);

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeRepository.deleteRecipe(recipeId);
  }
}
