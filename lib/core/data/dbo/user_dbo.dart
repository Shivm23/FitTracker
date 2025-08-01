import 'package:hive_flutter/hive_flutter.dart';
import 'package:opennutritracker/core/data/dbo/user_gender_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_pal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_role_dbo.dart';
import 'package:path/path.dart' as p;
import 'package:opennutritracker/core/domain/entity/user_entity.dart';

part 'user_dbo.g.dart';

@HiveType(typeId: 5)
class UserDBO extends HiveObject {
  @HiveField(0)
  DateTime birthday;
  @HiveField(1)
  double heightCM;
  @HiveField(2)
  double weightKG;
  @HiveField(3)
  UserGenderDBO gender;
  @HiveField(4)
  UserWeightGoalDBO goal;
  @HiveField(5)
  UserPALDBO pal;
  @HiveField(6)
  UserRoleDBO role;
  @HiveField(7)
  String? profileImagePath;
  @HiveField(8)
  String name;

  UserDBO(
      {required this.name,
      required this.birthday,
      required this.heightCM,
      required this.weightKG,
      required this.gender,
      required this.goal,
      required this.pal,
      required this.role,
      this.profileImagePath});

  factory UserDBO.fromUserEntity(UserEntity entity) {
    return UserDBO(
        name: entity.name,
        birthday: entity.birthday,
        heightCM: entity.heightCM,
        weightKG: entity.weightKG,
        gender: UserGenderDBO.fromUserGenderEntity(entity.gender),
        goal: UserWeightGoalDBO.fromUserWeightGoalEntity(entity.goal),
        pal: UserPALDBO.fromUserPALEntity(entity.pal),
        role: UserRoleDBO.fromUserRoleEntity(entity.role),
        profileImagePath: entity.profileImagePath != null
            ? p.basename(entity.profileImagePath!)
            : null);
  }
}
