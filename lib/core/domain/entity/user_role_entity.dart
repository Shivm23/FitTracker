import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/dbo/user_role_dbo.dart';
import 'package:opennutritracker/generated/l10n.dart';

enum UserRoleEntity {
  coach,
  student;

  factory UserRoleEntity.fromUserRoleDBO(UserRoleDBO roleDBO) {
    switch (roleDBO) {
      case UserRoleDBO.coach:
        return UserRoleEntity.coach;
      case UserRoleDBO.student:
        return UserRoleEntity.student;
    }
  }

  String getName(BuildContext context) {
    switch (this) {
      case UserRoleEntity.coach:
        return S.of(context).roleCoachLabel;
      case UserRoleEntity.student:
        return S.of(context).roleStudentLabel;
    }
  }

  IconData getIcon() {
    switch (this) {
      case UserRoleEntity.coach:
        return Icons.fitness_center_outlined;
      case UserRoleEntity.student:
        return Icons.school_outlined;
    }
  }
}
