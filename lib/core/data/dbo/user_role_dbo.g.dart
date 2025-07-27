// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRoleDBOAdapter extends TypeAdapter<UserRoleDBO> {
  @override
  final int typeId = 19;

  @override
  UserRoleDBO read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRoleDBO.coach;
      case 1:
        return UserRoleDBO.student;
      default:
        return UserRoleDBO.coach;
    }
  }

  @override
  void write(BinaryWriter writer, UserRoleDBO obj) {
    switch (obj) {
      case UserRoleDBO.coach:
        writer.writeByte(0);
        break;
      case UserRoleDBO.student:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
