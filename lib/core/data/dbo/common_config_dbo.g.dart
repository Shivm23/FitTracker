// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_config_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommonConfigDBOAdapter extends TypeAdapter<CommonConfigDBO> {
  @override
  final int typeId = 22;

  @override
  CommonConfigDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommonConfigDBO(
      fields[0] as AppThemeDBO,
    );
  }

  @override
  void write(BinaryWriter writer, CommonConfigDBO obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.selectedAppTheme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommonConfigDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonConfigDBO _$CommonConfigDBOFromJson(Map<String, dynamic> json) =>
    CommonConfigDBO(
      $enumDecode(_$AppThemeDBOEnumMap, json['selectedAppTheme']),
    );

Map<String, dynamic> _$CommonConfigDBOToJson(CommonConfigDBO instance) =>
    <String, dynamic>{
      'selectedAppTheme': _$AppThemeDBOEnumMap[instance.selectedAppTheme]!,
    };

const _$AppThemeDBOEnumMap = {
  AppThemeDBO.light: 'light',
  AppThemeDBO.dark: 'dark',
  AppThemeDBO.system: 'system',
};
