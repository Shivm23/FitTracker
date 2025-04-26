part of 'recipe_search_bloc.dart';

abstract class RecipeSearchEvent extends Equatable {
  const RecipeSearchEvent();
}

class LoadRecipeSearchEvent extends RecipeSearchEvent {
  final String searchString;

  /// an empty `searchString` will load all RecentMeal
  const LoadRecipeSearchEvent({required this.searchString});

  @override
  List<Object?> get props => [];
}

class DeleteRecipeEvent extends RecipeSearchEvent {
  final String recipeId;

  /// an empty `searchString` will load all RecentMeal
  const DeleteRecipeEvent({required this.recipeId});

  @override
  List<Object?> get props => [];
}
