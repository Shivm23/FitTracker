import 'package:opennutritracker/core/data/repository/macro_goal_repository.dart';
import 'package:opennutritracker/core/domain/entity/macro_goal_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class GetMacroGoalUsecase {
  final MacroGoalRepository _macroGoalRepository =
      locator<MacroGoalRepository>();

  GetMacroGoalUsecase();

  bool isSameOrAfterToday(DateTime target) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final targetDateOnly = DateTime(target.year, target.month, target.day);
    return targetDateOnly.isAfter(todayDateOnly) ||
        targetDateOnly == todayDateOnly;
  }

  Future<double?> getCarbsGoal() async {
    final macroGoal = await _macroGoalRepository.getMacroGoal();

    if (macroGoal != null && isSameOrAfterToday(macroGoal.date)) {
      return macroGoal.newCarbsGoal;
    }

    return macroGoal?.oldCarbsGoal;
  }

  Future<double?> getFatsGoal() async {
    final macroGoal = await _macroGoalRepository.getMacroGoal();

    if (macroGoal != null && isSameOrAfterToday(macroGoal.date)) {
      return macroGoal.newFatsGoal;
    }

    return macroGoal?.oldFatsGoal;
  }

  Future<double?> getProteinsGoal() async {
    final macroGoal = await _macroGoalRepository.getMacroGoal();

    if (macroGoal != null && isSameOrAfterToday(macroGoal.date)) {
      return macroGoal.newProteinsGoal;
    }

    return macroGoal?.oldProteinsGoal;
  }

  /// Optionnel : récupérer l'entité complète
  Future<MacroGoalEntity?> getMacroGoal() async {
    return await _macroGoalRepository.getMacroGoal();
  }
}
