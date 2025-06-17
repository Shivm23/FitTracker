import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opennutritracker/features/create_meal/create_meal_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:opennutritracker/features/create_meal/presentation/bloc/create_meal_bloc.dart';
import 'package:opennutritracker/core/domain/usecase/get_recipe_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';

import '../fixture/intake_for_recipe_fixtures.dart';

class MockGetRecipeUsecase extends Mock implements GetRecipeUsecase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CreateMealBloc bloc;
  setUp(() {
    bloc = CreateMealBloc(MockGetRecipeUsecase());
    locator.registerSingleton<CreateMealBloc>(bloc);
  });

  tearDown(() {
    locator.reset();
  });

  Widget buildWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const MealCreationScreen(),
    );
  }

  testWidgets('save button disabled with empty name or ingredients', (tester) async {
    await tester.pumpWidget(buildWidget());

    // Initially disabled
    var button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    // Only name -> still disabled
    await tester.enterText(find.byType(TextFormField).first, 'My recipe');
    await tester.pumpAndSettle();
    button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    // Add ingredient then rebuild
    bloc.add(SetIntakeListFromRecipeEvent([IntakeForRecipeFixtures.chicken]));
    await tester.pumpAndSettle();

    // Clear name -> disabled again
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.pumpAndSettle();
    button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
