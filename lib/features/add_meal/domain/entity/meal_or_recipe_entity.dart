import 'package:opennutritracker/core/data/dbo/meal_or_recipe_dbo.dart';

enum MealOrRecipeEntity {
  meal,
  recipe;

  factory MealOrRecipeEntity.fromMealOrRecipeDBO(MealOrRecipeDBO dbo) {
    switch (dbo) {
      case MealOrRecipeDBO.meal:
        return MealOrRecipeEntity.meal;
      case MealOrRecipeDBO.recipe:
        return MealOrRecipeEntity.recipe;
    }
  }
}
