import 'package:opennutritracker/core/domain/entity/recipe_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_for_recipe_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class RecipeEntityFixtures {
  static final meal = MealEntity(
    code: "test_meal_1",
    name: "Mocked Meal",
    brands: "MockBrand",
    url: "https://image.url",
    thumbnailImageUrl: "https://thumb.url",
    mainImageUrl: "https://main.url",
    mealQuantity: "1",
    mealUnit: "g",
    servingQuantity: 1,
    servingUnit: "g",
    servingSize: "100g",
    nutriments: MealNutrimentsEntity(
      energyKcalPerQuantity: 250,
      carbohydratesPerQuantity: 30,
      fatPerQuantity: 10,
      proteinsPerQuantity: 15,
      sugarsPerQuantity: 5,
      saturatedFatPerQuantity: 2,
      fiberPerQuantity: 4,
      mealOrRecipe: "recipe",
    ),
    source: MealSourceEntity.custom,
  );

  static final ingredients = [
    IntakeForRecipeEntity(
      code: "ingredient_1",
      name: "Rice",
      unit: "g",
      amount: 150,
      meal: meal,
    ),
    IntakeForRecipeEntity(
      code: "ingredient_2",
      name: "Chicken",
      unit: "g",
      amount: 100,
      meal: meal,
    ),
  ];

  static final basicRecipe = RecipeEntity(
    meal: meal,
    ingredients: ingredients,
  );
}

extension RecipeEntityCopyWith on RecipeEntity {
  RecipeEntity copyWith({
    MealEntity? meal,
    List<IntakeForRecipeEntity>? ingredients,
  }) {
    return RecipeEntity(
      meal: meal ?? this.meal,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
