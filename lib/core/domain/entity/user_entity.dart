import 'package:opennutritracker/core/data/dbo/user_dbo.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_role_entity.dart';

class UserEntity {
  String name;
  DateTime birthday;
  double heightCM;
  double weightKG;
  UserGenderEntity gender;
  UserWeightGoalEntity goal;
  UserPALEntity pal;
  UserRoleEntity role;
  String? profileImagePath;

  UserEntity(
      {required this.name,
      required this.birthday,
      required this.heightCM,
      required this.weightKG,
      required this.gender,
      required this.goal,
      required this.pal,
      required this.role,
      this.profileImagePath});

  UserEntity copyWith({
    String? name,
    DateTime? birthday,
    double? heightCM,
    double? weightKG,
    UserGenderEntity? gender,
    UserWeightGoalEntity? goal,
    UserPALEntity? pal,
    UserRoleEntity? role,
    String? profileImagePath,
  }) {
    return UserEntity(
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      heightCM: heightCM ?? this.heightCM,
      weightKG: weightKG ?? this.weightKG,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      pal: pal ?? this.pal,
      role: role ?? this.role,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  factory UserEntity.fromUserDBO(UserDBO userDBO) {
    return UserEntity(
        name: userDBO.name,
        birthday: userDBO.birthday,
        heightCM: userDBO.heightCM,
        weightKG: userDBO.weightKG,
        gender: UserGenderEntity.fromUserGenderDBO(userDBO.gender),
        goal: UserWeightGoalEntity.fromUserWeightGoalDBO(userDBO.goal),
        pal: UserPALEntity.fromUserPALDBO(userDBO.pal),
        role: UserRoleEntity.fromUserRoleDBO(userDBO.role),
        profileImagePath: userDBO.profileImagePath);
  }

  int get age => DateTime.now().difference(birthday).inDays ~/ 365;
}
