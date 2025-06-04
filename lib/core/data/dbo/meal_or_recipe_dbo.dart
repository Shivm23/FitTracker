import 'package:hive_flutter/hive_flutter.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_or_recipe_entity.dart';

part 'meal_or_recipe_dbo.g.dart';

@HiveType(typeId: 2)
enum MealOrRecipeDBO {
  @HiveField(0)
  meal,
  @HiveField(1)
  recipe;

  factory MealOrRecipeDBO.fromMealOrRecipeEntity(MealOrRecipeEntity entity) {
    switch (entity) {
      case MealOrRecipeEntity.meal:
        return MealOrRecipeDBO.meal;
      case MealOrRecipeEntity.recipe:
        return MealOrRecipeDBO.recipe;
    }
  }
}
