// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_nutriments_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealNutrimentsDBOAdapter extends TypeAdapter<MealNutrimentsDBO> {
  @override
  final int typeId = 3;

  @override
  MealNutrimentsDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealNutrimentsDBO(
      energyKcalPerQuantity: fields[0] as double?,
      carbohydratesPerQuantity: fields[1] as double?,
      fatPerQuantity: fields[2] as double?,
      proteinsPerQuantity: fields[3] as double?,
      sugarsPerQuantity: fields[4] as double?,
      saturatedFatPerQuantity: fields[5] as double?,
      fiberPerQuantity: fields[6] as double?,
      mealOrRecipe:
          (fields[7] as MealOrRecipeDBO?) ?? MealOrRecipeDBO.meal,
    );
  }

  @override
  void write(BinaryWriter writer, MealNutrimentsDBO obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.energyKcalPerQuantity)
      ..writeByte(1)
      ..write(obj.carbohydratesPerQuantity)
      ..writeByte(2)
      ..write(obj.fatPerQuantity)
      ..writeByte(3)
      ..write(obj.proteinsPerQuantity)
      ..writeByte(4)
      ..write(obj.sugarsPerQuantity)
      ..writeByte(5)
      ..write(obj.saturatedFatPerQuantity)
      ..writeByte(6)
      ..write(obj.fiberPerQuantity)
      ..writeByte(7)
      ..write(obj.mealOrRecipe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealNutrimentsDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealNutrimentsDBO _$MealNutrimentsDBOFromJson(Map<String, dynamic> json) =>
    MealNutrimentsDBO(
      energyKcalPerQuantity:
          (json['energyKcalPerQuantity'] as num?)?.toDouble(),
      carbohydratesPerQuantity:
          (json['carbohydratesPerQuantity'] as num?)?.toDouble(),
      fatPerQuantity: (json['fatPerQuantity'] as num?)?.toDouble(),
      proteinsPerQuantity: (json['proteinsPerQuantity'] as num?)?.toDouble(),
      sugarsPerQuantity: (json['sugarsPerQuantity'] as num?)?.toDouble(),
      saturatedFatPerQuantity:
          (json['saturatedFatPerQuantity'] as num?)?.toDouble(),
      fiberPerQuantity: (json['fiberPerQuantity'] as num?)?.toDouble(),
      mealOrRecipe: $enumDecode(_$MealOrRecipeDBOEnumMap, json['mealOrRecipe']),
    );

Map<String, dynamic> _$MealNutrimentsDBOToJson(MealNutrimentsDBO instance) =>
    <String, dynamic>{
      'energyKcalPerQuantity': instance.energyKcalPerQuantity,
      'carbohydratesPerQuantity': instance.carbohydratesPerQuantity,
      'fatPerQuantity': instance.fatPerQuantity,
      'proteinsPerQuantity': instance.proteinsPerQuantity,
      'sugarsPerQuantity': instance.sugarsPerQuantity,
      'saturatedFatPerQuantity': instance.saturatedFatPerQuantity,
      'fiberPerQuantity': instance.fiberPerQuantity,
      'mealOrRecipe': _$MealOrRecipeDBOEnumMap[instance.mealOrRecipe]!,
    };

const _$MealOrRecipeDBOEnumMap = {
  MealOrRecipeDBO.meal: 'meal',
  MealOrRecipeDBO.recipe: 'recipe',
};
