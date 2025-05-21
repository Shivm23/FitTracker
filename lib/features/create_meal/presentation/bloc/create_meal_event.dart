part of 'create_meal_bloc.dart';

abstract class CreateMealEvent extends Equatable {
  const CreateMealEvent();
}

class InitializeCreateMealEvent extends CreateMealEvent {
  const InitializeCreateMealEvent();

  @override
  List<Object?> get props => [];
}

class ExitCreateMealScreenEvent extends CreateMealEvent {
  const ExitCreateMealScreenEvent();

  @override
  List<Object?> get props => [];
}

class SetIntakeListFromRecipeEvent extends CreateMealEvent {
  final List<IntakeForRecipeEntity> ingredients;

  const SetIntakeListFromRecipeEvent(this.ingredients);

  @override
  List<Object?> get props => [ingredients];
}
