import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'intake_recipe_dbo.g.dart';

@HiveType(typeId: 16)
@JsonSerializable()
class IntakeForRecipeDBO extends HiveObject {
  @HiveField(0)
  String? code;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? unit;

  @HiveField(3)
  double? amount;

  @HiveField(4)
  MealDBO? meal;

  IntakeForRecipeDBO({
    this.code,
    this.name,
    this.unit,
    this.amount,
    this.meal,
  });

  factory IntakeForRecipeDBO.fromJson(Map<String, dynamic> json) =>
      _$IntakeForRecipeDBOFromJson(json);

  Map<String, dynamic> toJson() => _$IntakeForRecipeDBOToJson(this);
}
