import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
// TEMP: hide activities UI and navigation
// import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
// import 'package:opennutritracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_or_recipe_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class AddItemBottomSheet extends StatelessWidget {
  final DateTime day;

  const AddItemBottomSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TEMP: activities section hidden; keep only recipe quick action
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(
                    S.of(context).recipeLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    S.of(context).recipeLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(180)),
                  ),
                  leading: Icon(
                    Icons.receipt,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onTap: () => _showAddMealCreationScreen(context),
                ),
              ),
            ],
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: Text(
            S.of(context).breakfastLabel,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          subtitle: Text(
            S.of(context).breakfastExample,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7)),
          ),
          // ignore: sized_box_for_whitespace
          leading: Container(
              height: double.infinity,
              child: Icon(IntakeTypeEntity.breakfast.getIconData())),
          onTap: () {
            _showAddItemScreen(context, AddMealType.breakfastType);
          },
        ),
        ListTile(
          title: Text(
            S.of(context).lunchLabel,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          subtitle: Text(
            S.of(context).lunchExample,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7)),
          ),
          // ignore: sized_box_for_whitespace
          leading: Container(
              height: double.infinity,
              child: Icon(IntakeTypeEntity.lunch.getIconData())),
          onTap: () {
            _showAddItemScreen(context, AddMealType.lunchType);
          },
        ),
        ListTile(
          title: Text(
            S.of(context).dinnerLabel,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          subtitle: Text(
            S.of(context).dinnerExample,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7)),
          ),
          // ignore: sized_box_for_whitespace
          leading: Container(
              height: double.infinity,
              child: Icon(IntakeTypeEntity.dinner.getIconData())),
          onTap: () {
            _showAddItemScreen(context, AddMealType.dinnerType);
          },
        ),
        ListTile(
          title: Text(
            S.of(context).snackLabel,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          subtitle: Text(
            S.of(context).snackExample,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7)),
          ),
          // ignore: sized_box_for_whitespace
          leading: Container(
              height: double.infinity,
              child: Icon(IntakeTypeEntity.snack.getIconData())),
          onTap: () {
            _showAddItemScreen(context, AddMealType.snackType);
          },
        ),
      ],
    );
  }

  void _showAddItemScreen(BuildContext context, AddMealType itemType) {
    Navigator.of(context).pop(); // Close bottom sheet
    Navigator.of(context).pushNamed(NavigationOptions.addMealRoute,
        arguments: AddMealScreenArguments(
          itemType,
          day,
          MealOrRecipeEntity.meal,
        ));
  }

  // TEMP: disabled while activities are hidden
  // void _showAddActivityScreen(BuildContext context) {
  //   Navigator.of(context).pop();
  //   Navigator.of(context).pushNamed(NavigationOptions.addActivityRoute,
  //       arguments: AddActivityScreenArguments(day: day));
  // }

  void _showAddMealCreationScreen(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(
      NavigationOptions.recipeRoute,
    );
  }
}
