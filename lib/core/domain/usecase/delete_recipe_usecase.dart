import 'package:opennutritracker/core/data/repository/recipe_repository.dart';
import 'dart:io';
import 'package:opennutritracker/core/utils/path_helper.dart';

class DeleteRecipeUsecase {
  final RecipeRepository _recipeRepository;

  DeleteRecipeUsecase(this._recipeRepository);

  Future<void> deleteRecipe(String recipeId) async {
    final recipe = await _recipeRepository.getRecipeByKey(recipeId);

    if (recipe != null) {
      final paths = [
        recipe.meal.url,
        recipe.meal.thumbnailImageUrl,
        recipe.meal.mainImageUrl,
      ];
      for (final path in paths) {
        if (path != null && !path.startsWith('http')) {
          final file = File(await PathHelper.localImagePath(path));
          if (await file.exists()) {
            try {
              await file.delete();
            } catch (_) {
              // ignore deletion errors
            }
          }
        }
      }
    }
    await _recipeRepository.deleteRecipe(recipeId);
  }
}
