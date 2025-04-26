part of 'recipe_search_bloc.dart';

abstract class RecipeSearchState extends Equatable {
  const RecipeSearchState();
}

class RecipeInitial extends RecipeSearchState {
  @override
  List<Object> get props => [];
}

class RecipeLoadingState extends RecipeSearchState {
  @override
  List<Object?> get props => [];
}

class RecipeLoadedState extends RecipeSearchState {
  final List<MealEntity> recipes;
  final bool usesImperialUnits;

  const RecipeLoadedState(
      {required this.recipes, this.usesImperialUnits = false});

  @override
  List<Object?> get props => [recipes, usesImperialUnits];
}

class RecipeFailedState extends RecipeSearchState {
  @override
  List<Object?> get props => [];
}
