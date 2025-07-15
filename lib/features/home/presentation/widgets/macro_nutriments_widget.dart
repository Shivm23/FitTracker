import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:opennutritracker/generated/l10n.dart';

class MacroNutrientsView extends StatelessWidget {
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;

  const MacroNutrientsView({
    super.key,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _MacronutrientItem(
            intake: totalCarbsIntake,
            goal: totalCarbsGoal,
            label: S.of(context).carbsLabel,
          ),
        ),
        Expanded(
          child: _MacronutrientItem(
            intake: totalFatsIntake,
            goal: totalFatsGoal,
            label: S.of(context).fatLabel,
          ),
        ),
        Expanded(
          child: _MacronutrientItem(
            intake: totalProteinsIntake,
            goal: totalProteinsGoal,
            label: S.of(context).proteinLabel,
          ),
        ),
      ],
    );
  }
}

class _MacronutrientItem extends StatelessWidget {
  final double intake;
  final double goal;
  final String label;

  const _MacronutrientItem({
    required this.intake,
    required this.goal,
    required this.label,
  });

  double _getGoalPercentage(double goal, double supplied) {
    if (supplied <= 0 || goal <= 0) {
      return 0;
    } else if (supplied > goal) {
      return 1;
    } else {
      return supplied / goal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: 15.0,
          lineWidth: 6.0,
          animation: true,
          percent: _getGoalPercentage(goal, intake),
          progressColor: primaryColor,
          backgroundColor: primaryColor.withAlpha(50),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${intake.toInt()}/${goal.toInt()} g',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onSurfaceColor,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurfaceColor,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
