import 'package:hive/hive.dart';
import 'package:opennutritracker/core/domain/entity/user_role_entity.dart';

part 'user_role_dbo.g.dart';

@HiveType(typeId: 19)
enum UserRoleDBO {
  @HiveField(0)
  coach,
  @HiveField(1)
  student;

  factory UserRoleDBO.fromUserRoleEntity(UserRoleEntity roleEntity) {
    switch (roleEntity) {
      case UserRoleEntity.coach:
        return UserRoleDBO.coach;
      case UserRoleEntity.student:
        return UserRoleDBO.student;
    }
  }
}
