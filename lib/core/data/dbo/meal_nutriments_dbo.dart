import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

part 'meal_nutriments_dbo.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class MealNutrimentsDBO extends HiveObject {
  @HiveField(0)
  final double? energyKcalPerQuantity;
  @HiveField(1)
  final double? carbohydratesPerQuantity;
  @HiveField(2)
  final double? fatPerQuantity;
  @HiveField(3)
  final double? proteinsPerQuantity;
  @HiveField(4)
  final double? sugarsPerQuantity;
  @HiveField(5)
  final double? saturatedFatPerQuantity;
  @HiveField(6)
  final double? fiberPerQuantity;
  @HiveField(7)
  final String? mealOrRecipe;

  MealNutrimentsDBO(
      {required this.energyKcalPerQuantity,
      required this.carbohydratesPerQuantity,
      required this.fatPerQuantity,
      required this.proteinsPerQuantity,
      required this.sugarsPerQuantity,
      required this.saturatedFatPerQuantity,
      required this.fiberPerQuantity,
      required this.mealOrRecipe});

  factory MealNutrimentsDBO.fromProductNutrimentsEntity(
      MealNutrimentsEntity nutriments) {
    return MealNutrimentsDBO(
        energyKcalPerQuantity: nutriments.energyKcalPerQuantity,
        carbohydratesPerQuantity: nutriments.carbohydratesPerQuantity,
        fatPerQuantity: nutriments.fatPerQuantity,
        proteinsPerQuantity: nutriments.proteinsPerQuantity,
        sugarsPerQuantity: nutriments.sugarsPerQuantity,
        saturatedFatPerQuantity: nutriments.saturatedFatPerQuantity,
        fiberPerQuantity: nutriments.fiberPerQuantity,
        mealOrRecipe: nutriments.mealOrRecipe);
  }

  factory MealNutrimentsDBO.fromJson(Map<String, dynamic> json) =>
      _$MealNutrimentsDBOFromJson(json);

  Map<String, dynamic> toJson() => _$MealNutrimentsDBOToJson(this);
}
