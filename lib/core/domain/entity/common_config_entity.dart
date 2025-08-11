import 'package:equatable/equatable.dart';
import 'package:opennutritracker/core/data/dbo/common_config_dbo.dart';
import 'package:opennutritracker/core/domain/entity/app_theme_entity.dart';

class CommonConfigEntity extends Equatable {
  final AppThemeEntity appTheme;

  const CommonConfigEntity(this.appTheme);

  factory CommonConfigEntity.fromConfigDBO(CommonConfigDBO dbo) =>
      CommonConfigEntity(
        AppThemeEntity.fromAppThemeDBO(dbo.selectedAppTheme),
      );

  @override
  List<Object?> get props => [
        appTheme,
      ];
}
