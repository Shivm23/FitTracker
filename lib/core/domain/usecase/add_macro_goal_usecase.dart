import 'package:opennutritracker/core/data/repository/macro_goal_repository.dart';
import 'package:opennutritracker/core/domain/entity/macro_goal_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMacroGoalUsecase {
  final MacroGoalRepository _macroGoalRepository =
      locator<MacroGoalRepository>();
  final SupabaseClient _supabaseClient = locator<SupabaseClient>();

  Future<void> addMacroGoalFromCoach() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // 1. Fetch macro goals depuis Supabase
    final response = await _supabaseClient
        .from('coach_macro_goals')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) throw Exception('No goal found for this user');

    // 2. Récupère l’ancien goal s’il existe
    final oldEntity = await _macroGoalRepository.getMacroGoal();

    final newMacro = MacroGoalEntity(
      id: userId,
      date: DateTime.parse(response['start_date']),
      oldCarbsGoal: oldEntity?.newCarbsGoal ?? 0,
      oldFatsGoal: oldEntity?.newFatsGoal ?? 0,
      oldProteinsGoal: oldEntity?.newProteinsGoal ?? 0,
      newCarbsGoal: (response['carb_goal'] as num).toDouble(),
      newFatsGoal: (response['fat_goal'] as num).toDouble(),
      newProteinsGoal: (response['protein_goal'] as num).toDouble(),
    );

    // 3. Sauvegarde dans Hive via repository
    await _macroGoalRepository.saveMacroGoal(newMacro);
  }

  Future<void> addMacroGoal(
      double newProteinsGoal, double newCarbsGoal, double newFatsGoal) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final newMacro = MacroGoalEntity(
      id: userId,
      date: DateTime.now(),
      oldCarbsGoal: newCarbsGoal,
      oldFatsGoal: newFatsGoal,
      oldProteinsGoal: newProteinsGoal,
      newCarbsGoal: newCarbsGoal,
      newFatsGoal: newFatsGoal,
      newProteinsGoal: newProteinsGoal,
    );

    await _macroGoalRepository.saveMacroGoal(newMacro);
  }
}
