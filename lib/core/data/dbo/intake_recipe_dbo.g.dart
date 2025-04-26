// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_recipe_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntakeForRecipeDBOAdapter extends TypeAdapter<IntakeForRecipeDBO> {
  @override
  final int typeId = 16;

  @override
  IntakeForRecipeDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntakeForRecipeDBO(
      code: fields[0] as String?,
      name: fields[1] as String?,
      unit: fields[2] as String?,
      amount: fields[3] as double?,
      meal: fields[4] as MealDBO?,
    );
  }

  @override
  void write(BinaryWriter writer, IntakeForRecipeDBO obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.meal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntakeForRecipeDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntakeForRecipeDBO _$IntakeForRecipeDBOFromJson(Map<String, dynamic> json) =>
    IntakeForRecipeDBO(
      code: json['code'] as String?,
      name: json['name'] as String?,
      unit: json['unit'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      meal: json['meal'] == null
          ? null
          : MealDBO.fromJson(json['meal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IntakeForRecipeDBOToJson(IntakeForRecipeDBO instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'unit': instance.unit,
      'amount': instance.amount,
      'meal': instance.meal,
    };
