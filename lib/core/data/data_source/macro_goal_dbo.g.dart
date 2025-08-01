// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro_goal_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MacroGoalDboAdapter extends TypeAdapter<MacroGoalDbo> {
  @override
  final int typeId = 20;

  @override
  MacroGoalDbo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MacroGoalDbo(
      fields[0] as String,
      fields[1] as DateTime,
      fields[2] as double,
      fields[3] as double,
      fields[4] as double,
      fields[5] as double,
      fields[6] as double,
      fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MacroGoalDbo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.oldCarbsGoal)
      ..writeByte(3)
      ..write(obj.oldFatsGoal)
      ..writeByte(4)
      ..write(obj.oldProteinsGoal)
      ..writeByte(5)
      ..write(obj.newCarbsGoal)
      ..writeByte(6)
      ..write(obj.newFatsGoal)
      ..writeByte(7)
      ..write(obj.newProteinsGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacroGoalDboAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MacroGoalDbo _$MacroGoalDboFromJson(Map<String, dynamic> json) => MacroGoalDbo(
      json['id'] as String,
      DateTime.parse(json['date'] as String),
      (json['oldCarbsGoal'] as num).toDouble(),
      (json['oldFatsGoal'] as num).toDouble(),
      (json['oldProteinsGoal'] as num).toDouble(),
      (json['newCarbsGoal'] as num).toDouble(),
      (json['newFatsGoal'] as num).toDouble(),
      (json['newProteinsGoal'] as num).toDouble(),
    );

Map<String, dynamic> _$MacroGoalDboToJson(MacroGoalDbo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'oldCarbsGoal': instance.oldCarbsGoal,
      'oldFatsGoal': instance.oldFatsGoal,
      'oldProteinsGoal': instance.oldProteinsGoal,
      'newCarbsGoal': instance.newCarbsGoal,
      'newFatsGoal': instance.newFatsGoal,
      'newProteinsGoal': instance.newProteinsGoal,
    };
