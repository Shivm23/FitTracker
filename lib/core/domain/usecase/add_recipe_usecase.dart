import 'package:opennutritracker/core/data/repository/recipe_repository.dart';
import 'package:opennutritracker/core/domain/entity/recipe_entity.dart';

class AddRecipeUsecase {
  final RecipeRepository _recipeRepository;

  AddRecipeUsecase(this._recipeRepository);

  Future<void> addRecipe(RecipeEntity recipeEntity) async {
    return await _recipeRepository.addRecipe(recipeEntity);
  }
}
