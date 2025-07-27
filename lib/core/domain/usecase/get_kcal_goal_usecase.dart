import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class GetKcalGoalUsecase {
  GetKcalGoalUsecase();

  Future<double> getKcalGoal() async {
    final getMacroGoalUsecase = locator<GetMacroGoalUsecase>();
    final protein = await getMacroGoalUsecase.getProteinsGoal() ?? 120;
    final carbs = await getMacroGoalUsecase.getCarbsGoal() ?? 250;
    final fats = await getMacroGoalUsecase.getFatsGoal() ?? 60;
    final kcal = protein * 4 + carbs * 4 + fats * 9;
    return kcal;
  }
}
