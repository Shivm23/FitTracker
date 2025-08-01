import 'package:opennutritracker/core/data/data_source/macro_goal_data_source.dart';
import 'package:opennutritracker/core/domain/entity/macro_goal_entity.dart';

class MacroGoalRepository {
  final MacroGoalDataSource _macroGoalDataSource;

  MacroGoalRepository(this._macroGoalDataSource);

  Future<void> saveMacroGoal(MacroGoalEntity macroGoal) async {
    final dbo = macroGoal.toDbo();
    await _macroGoalDataSource.saveMacroGoal(dbo);
  }

  Future<MacroGoalEntity?> getMacroGoal() async {
    final dbo = await _macroGoalDataSource.getMacroGoal();
    if (dbo == null) return null;
    return MacroGoalEntity.fromDbo(dbo);
  }

  Future<void> deleteMacroGoal() async {
    await _macroGoalDataSource.deleteMacroGoal();
  }

  Future<bool> hasMacroGoal() async {
    return await _macroGoalDataSource.hasMacroGoal();
  }
}
