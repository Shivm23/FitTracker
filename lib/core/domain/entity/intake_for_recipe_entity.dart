import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

class IntakeForRecipeEntity extends Equatable {
  final String? code;
  final String? name;
  final String? unit;
  final double? amount;
  final MealEntity? meal;

  const IntakeForRecipeEntity({
    this.code,
    this.name,
    this.unit,
    this.amount,
    this.meal,
  });

  @override
  List<Object?> get props => [code, name, unit, amount, meal];

  /// Copie modifiable
  IntakeForRecipeEntity copyWith({
    String? code,
    String? name,
    String? unit,
    double? amount,
    MealEntity? meal,
  }) {
    return IntakeForRecipeEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      meal: meal ?? this.meal,
    );
  }
}
