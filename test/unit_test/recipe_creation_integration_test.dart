import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opennutritracker/core/data/data_source/recipe_data_source.dart';
import 'package:opennutritracker/core/utils/hive_db_provider.dart';
import 'package:opennutritracker/core/data/dbo/intake_recipe_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_or_recipe_dbo.dart';
import 'package:opennutritracker/core/data/dbo/recipe_dbo.dart';
import 'package:opennutritracker/core/data/repository/recipe_repository.dart';
import 'package:opennutritracker/core/domain/entity/recipe_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_recipe_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_recipe_usecase.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_or_recipe_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/create_meal/presentation/bloc/create_meal_bloc.dart';

import '../fixture/intake_for_recipe_fixtures.dart';

class MockGetRecipeUsecase extends Mock implements GetRecipeUsecase {}

void main() {
  group('Recipe creation flow', () {
    late Box<RecipesDBO> box;
    late Directory tempDir;
    late CreateMealBloc bloc;
    late AddRecipeUsecase addUsecase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);

      Hive.registerAdapter(RecipesDBOAdapter());
      Hive.registerAdapter(MealDBOAdapter());
      Hive.registerAdapter(MealNutrimentsDBOAdapter());
      Hive.registerAdapter(MealSourceDBOAdapter());
      Hive.registerAdapter(IntakeForRecipeDBOAdapter());
      Hive.registerAdapter(MealOrRecipeDBOAdapter());

      box = await Hive.openBox<RecipesDBO>('recipes_test');
      final hive = HiveDBProvider();
      hive.recipeBox = box;
      final dataSource = RecipesDataSource(hive);
      final repo = RecipeRepository(dataSource);
      addUsecase = AddRecipeUsecase(repo);

      bloc = CreateMealBloc(MockGetRecipeUsecase());
    });

    tearDown(() async {
      await box.close();
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test('create recipe from bloc emits correct state and saves to db', () async {
      await bloc.addIntake(
          'g',
          '100',
          IntakeTypeEntity.breakfast,
          IntakeForRecipeFixtures.chicken.meal!,
          DateTime.now());
      await bloc.addIntake(
          'g',
          '150',
          IntakeTypeEntity.lunch,
          IntakeForRecipeFixtures.rice.meal!,
          DateTime.now());

      expect(bloc.state.intakeList.length, 2);

      final macros = bloc.computeMacros();
      expect(macros['totalProteins'], closeTo(34.75, 0.01));

      const portions = 2;
      final meal = MealEntity(
        code: 'integration_meal',
        name: 'Recipe',
        url: null,
        mealQuantity: '$portions',
        mealUnit: 'serving',
        servingQuantity: 1,
        servingUnit: 'serving',
        servingSize: '100g',
        nutriments: MealNutrimentsEntity(
          energyKcalPerQuantity: macros['totalKcal']! / portions,
          carbohydratesPerQuantity: macros['totalCarbs']! / portions,
          fatPerQuantity: macros['totalFats']! / portions,
          proteinsPerQuantity: macros['totalProteins']! / portions,
          sugarsPerQuantity: null,
          saturatedFatPerQuantity: null,
          fiberPerQuantity: null,
          mealOrRecipe: MealOrRecipeEntity.recipe,
        ),
        source: MealSourceEntity.custom,
      );

      final recipe = RecipeEntity(
        meal: meal,
        ingredients: bloc.getListOfIntakeForRecipeEntity(),
      );

      await addUsecase.addRecipe(recipe);

      expect(box.values.length, 1);

      bloc.clearIntakeList();
      expect(bloc.state.intakeList, isEmpty);
    });
  });
}
