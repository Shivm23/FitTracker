// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_or_recipe_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealOrRecipeDBOAdapter extends TypeAdapter<MealOrRecipeDBO> {
  @override
  final int typeId = 2;

  @override
  MealOrRecipeDBO read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealOrRecipeDBO.meal;
      case 1:
        return MealOrRecipeDBO.recipe;
      default:
        return MealOrRecipeDBO.meal;
    }
  }

  @override
  void write(BinaryWriter writer, MealOrRecipeDBO obj) {
    switch (obj) {
      case MealOrRecipeDBO.meal:
        writer.writeByte(0);
        break;
      case MealOrRecipeDBO.recipe:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealOrRecipeDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
