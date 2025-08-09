import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/data/dbo/app_theme_dbo.dart';

part 'common_config_dbo.g.dart';

/// Used to store config data that is not linked to a user
@HiveType(typeId: 22)
@JsonSerializable()
class CommonConfigDBO extends HiveObject {
  @HiveField(0)
  AppThemeDBO selectedAppTheme;

  factory CommonConfigDBO.empty() => CommonConfigDBO(AppThemeDBO.system);

  CommonConfigDBO(this.selectedAppTheme);

  factory CommonConfigDBO.fromJson(Map<String, dynamic> json) =>
      _$CommonConfigDBOFromJson(json);

  Map<String, dynamic> toJson() => _$CommonConfigDBOToJson(this);
}
