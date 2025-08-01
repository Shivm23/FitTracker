import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class GetKcalGoalUsecase {
  GetKcalGoalUsecase();

  Future<double> getKcalGoal() async {
    final getMacroGoalUsecase = locator<GetMacroGoalUsecase>();
    final protein = await getMacroGoalUsecase.getProteinsGoal();
    final carbs = await getMacroGoalUsecase.getCarbsGoal();
    final fats = await getMacroGoalUsecase.getFatsGoal();
    final kcal = protein * 4 + carbs * 4 + fats * 9;
    return kcal;
  }
}
