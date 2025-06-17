import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:opennutritracker/core/data/data_source/recipe_data_source.dart';
import 'package:opennutritracker/core/data/dbo/intake_recipe_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:opennutritracker/core/data/dbo/meal_or_recipe_dbo.dart';
import 'package:opennutritracker/core/data/dbo/recipe_dbo.dart';
import 'package:opennutritracker/core/data/repository/recipe_repository.dart';
import 'package:opennutritracker/core/domain/usecase/add_recipe_usecase.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

import '../fixture/recipe_entity_fixtures.dart';

void main() {
  group('AddRecipeUsecase', () {
    late Directory tempDir;
    late Box<RecipesDBO> box;
    late AddRecipeUsecase usecase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp('hive_test_add_');
      Hive.init(tempDir.path);

      Hive.registerAdapter(RecipesDBOAdapter());
      Hive.registerAdapter(MealDBOAdapter());
      Hive.registerAdapter(MealNutrimentsDBOAdapter());
      Hive.registerAdapter(MealSourceDBOAdapter());
      Hive.registerAdapter(IntakeForRecipeDBOAdapter());
      Hive.registerAdapter(MealOrRecipeDBOAdapter());

      box = await Hive.openBox<RecipesDBO>('recipes_test');
      final repo = RecipeRepository(RecipesDataSource(box));
      usecase = AddRecipeUsecase(repo);
    });

    tearDown(() async {
      await box.close();
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test('saves recipe with portion information', () async {
      final recipe = RecipeEntityFixtures.basicRecipe.copyWith(
        meal: RecipeEntityFixtures.basicRecipe.meal.copyWith(
          mealQuantity: '4',
          mealUnit: 'serving',
        ),
      );

      await usecase.addRecipe(recipe);

      final stored = box.values.first;
      expect(stored.recipe.mealQuantity, '4');
      expect(stored.recipe.mealUnit, 'serving');
    });
  });
}
