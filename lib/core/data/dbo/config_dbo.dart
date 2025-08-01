import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/data/dbo/app_theme_dbo.dart';
import 'package:opennutritracker/core/domain/entity/config_entity.dart';

part 'config_dbo.g.dart';

@HiveType(typeId: 13)
@JsonSerializable() // Used for exporting to JSON
class ConfigDBO extends HiveObject {
  @HiveField(0)
  bool hasAcceptedDisclaimer;
  @HiveField(1)
  bool hasAcceptedPolicy;
  @HiveField(2)
  bool hasAcceptedSendAnonymousData;
  @HiveField(3)
  AppThemeDBO selectedAppTheme;
  @HiveField(4)
  bool? usesImperialUnits;
  @HiveField(5)
  double? userKcalAdjustment;
  @HiveField(6)
  double? userCarbGoal;
  @HiveField(7)
  double? userProteinGoal;
  @HiveField(8)
  double? userFatGoal;
  @HiveField(9)
  DateTime? lastDataUpdate;
  @HiveField(10)
  bool supabaseSyncEnabled;

  ConfigDBO(this.hasAcceptedDisclaimer, this.hasAcceptedPolicy,
      this.hasAcceptedSendAnonymousData, this.selectedAppTheme,
      {this.usesImperialUnits = false,
      this.userKcalAdjustment,
      this.lastDataUpdate,
      this.supabaseSyncEnabled = true});

  factory ConfigDBO.empty() => ConfigDBO(
        true,
        false,
        false,
        AppThemeDBO.system,
      )
        ..userCarbGoal = 250
        ..userProteinGoal = 120
        ..userFatGoal = 60
        ..supabaseSyncEnabled = true;

  factory ConfigDBO.fromConfigEntity(ConfigEntity entity) => ConfigDBO(
      entity.hasAcceptedDisclaimer,
      entity.hasAcceptedPolicy,
      entity.hasAcceptedSendAnonymousData,
      AppThemeDBO.fromAppThemeEntity(entity.appTheme),
      usesImperialUnits: entity.usesImperialUnits,
      lastDataUpdate: entity.lastDataUpdate,
      supabaseSyncEnabled: entity.supabaseSyncEnabled);

  factory ConfigDBO.fromJson(Map<String, dynamic> json) =>
      _$ConfigDBOFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigDBOToJson(this);
}
