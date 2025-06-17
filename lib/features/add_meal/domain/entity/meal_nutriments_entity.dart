import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_or_recipe_entity.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_const.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_food_nutriment_dto.dart';
import 'package:opennutritracker/features/add_meal/data/dto/off/off_product_nutriments_dto.dart';

class MealNutrimentsEntity extends Equatable {
  final double? energyKcalPerQuantity;

  final double? carbohydratesPerQuantity;
  final double? fatPerQuantity;
  final double? proteinsPerQuantity;
  final double? sugarsPerQuantity;
  final double? saturatedFatPerQuantity;
  final double? fiberPerQuantity;
  final MealOrRecipeEntity mealOrRecipe;

  double? get energyPerUnit => _getValuePerUnit(energyKcalPerQuantity);

  double? get carbohydratesPerUnit =>
      _getValuePerUnit(carbohydratesPerQuantity);

  double? get fatPerUnit => _getValuePerUnit(fatPerQuantity);

  double? get proteinsPerUnit => _getValuePerUnit(proteinsPerQuantity);

  const MealNutrimentsEntity(
      {required this.energyKcalPerQuantity,
      required this.carbohydratesPerQuantity,
      required this.fatPerQuantity,
      required this.proteinsPerQuantity,
      required this.sugarsPerQuantity,
      required this.saturatedFatPerQuantity,
      required this.fiberPerQuantity,
      required this.mealOrRecipe});

  factory MealNutrimentsEntity.empty() => const MealNutrimentsEntity(
      energyKcalPerQuantity: null,
      carbohydratesPerQuantity: null,
      fatPerQuantity: null,
      proteinsPerQuantity: null,
      sugarsPerQuantity: null,
      saturatedFatPerQuantity: null,
      fiberPerQuantity: null,
      mealOrRecipe: MealOrRecipeEntity.meal);

  factory MealNutrimentsEntity.fromMealNutrimentsDBO(
      MealNutrimentsDBO nutriments) {
    return MealNutrimentsEntity(
        energyKcalPerQuantity: nutriments.energyKcalPerQuantity,
        carbohydratesPerQuantity: nutriments.carbohydratesPerQuantity,
        fatPerQuantity: nutriments.fatPerQuantity,
        proteinsPerQuantity: nutriments.proteinsPerQuantity,
        sugarsPerQuantity: nutriments.sugarsPerQuantity,
        saturatedFatPerQuantity: nutriments.saturatedFatPerQuantity,
        fiberPerQuantity: nutriments.fiberPerQuantity,
        mealOrRecipe:
            MealOrRecipeEntity.fromMealOrRecipeDBO(nutriments.mealOrRecipe));
  }

  factory MealNutrimentsEntity.fromOffNutriments(
      OFFProductNutrimentsDTO offNutriments) {
    // 1. OFF product nutriments can either be String, int, double or null
    // 2. Extension function asDoubleOrNull does not work on a dynamic data
    // type, so cast to it Object?
    return MealNutrimentsEntity(
        energyKcalPerQuantity:
            (offNutriments.energy_kcal_100g as Object?).asDoubleOrNull(),
        carbohydratesPerQuantity:
            (offNutriments.carbohydrates_100g as Object?).asDoubleOrNull(),
        fatPerQuantity: (offNutriments.fat_100g as Object?).asDoubleOrNull(),
        proteinsPerQuantity:
            (offNutriments.proteins_100g as Object?).asDoubleOrNull(),
        sugarsPerQuantity:
            (offNutriments.sugars_100g as Object?).asDoubleOrNull(),
        saturatedFatPerQuantity:
            (offNutriments.saturated_fat_100g as Object?).asDoubleOrNull(),
        fiberPerQuantity:
            (offNutriments.fiber_100g as Object?).asDoubleOrNull(),
        mealOrRecipe: MealOrRecipeEntity.meal);
  }

  factory MealNutrimentsEntity.fromFDCNutriments(
      List<FDCFoodNutrimentDTO> fdcNutriment) {
    // FDC Food nutriments can have different values for Energy [Energy,
    // Energy (Atwater General Factors), Energy (Atwater Specific Factors)]
    final energyTotal = fdcNutriment
            .firstWhereOrNull(
                (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalKcalId)
            ?.amount ??
        fdcNutriment
            .firstWhereOrNull((nutriment) =>
                nutriment.nutrientId == FDCConst.fdcKcalAtwaterGeneralId)
            ?.amount ??
        fdcNutriment
            .firstWhereOrNull((nutriment) =>
                nutriment.nutrientId == FDCConst.fdcKcalAtwaterSpecificId)
            ?.amount;

    final carbsTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalCarbsId)
        ?.amount;

    final fatTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalFatId)
        ?.amount;

    final proteinsTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalProteinsId)
        ?.amount;

    final sugarTotal = fdcNutriment
        .firstWhereOrNull(
            (nutriment) => nutriment.nutrientId == FDCConst.fdcTotalSugarId)
        ?.amount;

    final saturatedFatTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalSaturatedFatId)
        ?.amount;

    final fiberTotal = fdcNutriment
        .firstWhereOrNull((nutriment) =>
            nutriment.nutrientId == FDCConst.fdcTotalDietaryFiberId)
        ?.amount;

    return MealNutrimentsEntity(
        energyKcalPerQuantity: energyTotal,
        carbohydratesPerQuantity: carbsTotal,
        fatPerQuantity: fatTotal,
        proteinsPerQuantity: proteinsTotal,
        sugarsPerQuantity: sugarTotal,
        saturatedFatPerQuantity: saturatedFatTotal,
        fiberPerQuantity: fiberTotal,
        mealOrRecipe: MealOrRecipeEntity.meal);
  }

  double? _getValuePerUnit(double? valuePerPerQuantity) {
    if (mealOrRecipe == MealOrRecipeEntity.recipe && valuePerPerQuantity != null) {
      return valuePerPerQuantity;
    } else if (valuePerPerQuantity != null) {
      return valuePerPerQuantity / 100;
    } else {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        energyKcalPerQuantity,
        carbohydratesPerQuantity,
        fatPerQuantity,
        proteinsPerQuantity
      ];
}
