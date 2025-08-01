import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_macro_goal_usecase.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:flutter/material.dart';

class CalculationsDialog extends StatefulWidget {
  const CalculationsDialog({super.key});

  @override
  State<CalculationsDialog> createState() => _CalculationsDialogState();
}

class _CalculationsDialogState extends State<CalculationsDialog> {
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();

  double _calculatedKcal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMacroGoals();
  }

  Future<void> _loadMacroGoals() async {
    final getMacroGoalUsecase = locator<GetMacroGoalUsecase>();

    final protein = await getMacroGoalUsecase.getProteinsGoal();
    final carbs = await getMacroGoalUsecase.getCarbsGoal();
    final fats = await getMacroGoalUsecase.getFatsGoal();

    _proteinController.text = protein.toString();
    _carbsController.text = carbs.toString();
    _fatsController.text = fats.toString();

    _updateKcal();
    setState(() => _loading = false);
  }

  void _updateKcal() {
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fats = double.tryParse(_fatsController.text) ?? 0;

    setState(() {
      _calculatedKcal = (protein * 4) + (carbs * 4) + (fats * 9);
    });
  }

  Future<void> _saveMacroGoals() async {
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fats = double.tryParse(_fatsController.text) ?? 0;

    final addMacroGoalUsecase = locator<AddMacroGoalUsecase>();

    try {
      await addMacroGoalUsecase.addMacroGoal(protein, carbs, fats);

      if (!mounted) return;
      // Refresh Home Page
      locator<HomeBloc>().add(const LoadItemsEvent());
      // Refresh Diary Page
      locator<DiaryBloc>().add(const LoadDiaryYearEvent());
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("error saving macro goals: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).settingsCalculationsLabel),
      content: _loading
          ? const SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMacroField(
                    S.of(context).proteinLabel, _proteinController),
                _buildMacroField(S.of(context).carbsLabel, _carbsController),
                _buildMacroField(S.of(context).fatLabel, _fatsController),
                const SizedBox(height: 24),
                Text('${S.of(context).kcalLabel}: ${_calculatedKcal.round()}'),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogCancelLabel),
        ),
        TextButton(
          onPressed: _saveMacroGoals,
          child: Text(S.of(context).dialogOKLabel),
        ),
      ],
    );
  }

  Widget _buildMacroField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$label (g)',
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => _updateKcal(),
      ),
    );
  }
}
