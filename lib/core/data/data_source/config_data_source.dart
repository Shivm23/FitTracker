import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/dbo/app_theme_dbo.dart';
import 'package:opennutritracker/core/data/dbo/config_dbo.dart';
import 'package:opennutritracker/core/utils/hive_db_provider.dart';

class ConfigDataSource {
  static const _configKey = "ConfigKey";

  final _log = Logger('ConfigDataSource');
  final HiveDBProvider _hive;

  ConfigDataSource(this._hive);

  Future<bool> configInitialized() async => _hive.configBox.containsKey(_configKey);

  Future<void> initializeConfig() async =>
      _hive.configBox.put(_configKey, ConfigDBO.empty());

  Future<void> addConfig(ConfigDBO configDBO) async {
    _log.fine('Adding new config item to db');
    _hive.configBox.put(_configKey, configDBO);
  }

  Future<void> setConfigAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _log.fine(
        'Updating config hasAcceptedAnonymousData to $hasAcceptedAnonymousData');
    final config = _hive.configBox.get(_configKey);
    config?.hasAcceptedSendAnonymousData = hasAcceptedAnonymousData;
    await config?.save();
  }

  Future<AppThemeDBO> getAppTheme() async {
    final config = _hive.configBox.get(_configKey);
    return config?.selectedAppTheme ?? AppThemeDBO.defaultTheme;
  }

  Future<void> setConfigAppTheme(AppThemeDBO appTheme) async {
    _log.fine('Updating config appTheme to $appTheme');
    final config = _hive.configBox.get(_configKey);
    config?.selectedAppTheme = appTheme;
    await config?.save();
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _log.fine('Updating config usesImperialUnits to $usesImperialUnits');
    final config = _hive.configBox.get(_configKey);
    config?.usesImperialUnits = usesImperialUnits;
    await config?.save();
  }

  Future<double> getKcalAdjustment() async {
    final config = _hive.configBox.get(_configKey);
    return config?.userKcalAdjustment ?? 0;
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _log.fine('Updating config kcalAdjustment to $kcalAdjustment');
    final config = _hive.configBox.get(_configKey);
    config?.userKcalAdjustment = kcalAdjustment;
    await config?.save();
  }

  Future<void> setConfigCarbGoal(double carbGoal) async {
    _log.fine('Updating config carbGoal to $carbGoal');
    final config = _hive.configBox.get(_configKey);
    config?.userCarbGoal = carbGoal;
    await config?.save();
  }

  Future<void> setConfigProteinGoal(double proteinGoal) async {
    _log.fine('Updating config proteinGoal to $proteinGoal');
    final config = _hive.configBox.get(_configKey);
    config?.userProteinGoal = proteinGoal;
    await config?.save();
  }

  Future<void> setConfigFatGoal(double fatGoal) async {
    _log.fine('Updating config fatGoal to $fatGoal');
    final config = _hive.configBox.get(_configKey);
    config?.userFatGoal = fatGoal;
    await config?.save();
  }

  Future<ConfigDBO> getConfig() async {
    return _hive.configBox.get(_configKey) ?? ConfigDBO.empty();
  }

  Future<bool> getHasAcceptedAnonymousData() async {
    final config = _hive.configBox.get(_configKey);
    return config?.hasAcceptedSendAnonymousData ?? false;
  }

  Future<void> setLastDataUpdate(DateTime date) async {
    final config = _hive.configBox.get(_configKey);
    config?.lastDataUpdate = date;
    await config?.save();
  }

  Future<DateTime?> getLastDataUpdate() async {
    final config = _hive.configBox.get(_configKey);
    return config?.lastDataUpdate;
  }
}
