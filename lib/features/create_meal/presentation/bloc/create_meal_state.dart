part of 'create_meal_bloc.dart';

class CreateMealState extends Equatable {
  final bool isOnCreateMealScreen;
  final List<IntakeForRecipeEntity> intakeList;

  final double totalProteins;
  final double totalCarbs;
  final double totalFats;

  const CreateMealState({
    this.isOnCreateMealScreen = false,
    this.intakeList = const [],
    this.totalProteins = 0,
    this.totalCarbs = 0,
    this.totalFats = 0,
  });

  CreateMealState copyWith(
      {List<IntakeForRecipeEntity>? intakeList,
      bool? isOnCreateMealScreen,
      double? totalProteins,
      double? totalCarbs,
      double? totalFats}) {
    return CreateMealState(
        intakeList: intakeList ?? this.intakeList,
        isOnCreateMealScreen: isOnCreateMealScreen ?? this.isOnCreateMealScreen,
        totalProteins: totalProteins ?? this.totalProteins,
        totalCarbs: totalCarbs ?? this.totalCarbs,
        totalFats: totalFats ?? this.totalFats);
  }

  @override
  List<Object?> get props =>
      [intakeList, isOnCreateMealScreen, totalProteins, totalCarbs, totalFats];
}
