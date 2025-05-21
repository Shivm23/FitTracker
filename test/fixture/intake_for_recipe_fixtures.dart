import 'package:opennutritracker/core/domain/entity/intake_for_recipe_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

class IntakeForRecipeFixtures {
  static final chicken = IntakeForRecipeEntity(
    code: '1',
    name: 'Chicken Breast',
    amount: 100,
    unit: 'g',
    meal: MealEntity(
      code: '1',
      name: 'Chicken Breast',
      url: '',
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: 100,
      servingUnit: 'g',
      servingSize: '100g',
      nutriments: MealNutrimentsEntity(
        energyKcalPerQuantity: 165,
        carbohydratesPerQuantity: 0,
        fatPerQuantity: 3,
        proteinsPerQuantity: 31,
        sugarsPerQuantity: 0,
        saturatedFatPerQuantity: 1,
        fiberPerQuantity: 0,
        mealOrRecipe: 'meal',
      ),
      source: MealSourceEntity.custom,
    ),
  );

  static final rice = IntakeForRecipeEntity(
    code: '2',
    name: 'Rice',
    amount: 150,
    unit: 'g',
    meal: MealEntity(
      code: '2',
      name: 'Rice',
      url: '',
      mealQuantity: '150',
      mealUnit: 'g',
      servingQuantity: 100,
      servingUnit: 'g',
      servingSize: '100g',
      nutriments: MealNutrimentsEntity(
        energyKcalPerQuantity: 130,
        carbohydratesPerQuantity: 28,
        fatPerQuantity: 1,
        proteinsPerQuantity: 2.5,
        sugarsPerQuantity: 0,
        saturatedFatPerQuantity: 0,
        fiberPerQuantity: 0,
        mealOrRecipe: 'meal',
      ),
      source: MealSourceEntity.custom,
    ),
  );
}
