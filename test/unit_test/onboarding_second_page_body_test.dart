import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/onboarding_second_page_body.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Troca de unidade altera label do campo de peso (kg/lbs)',
      (WidgetTester tester) async {
    bool buttonActive = false;
    double? selectedHeight;
    double? selectedWeight;
    bool? usesImperialUnits;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: OnboardingSecondPageBody(
            setButtonContent: (active, height, weight, imperial) {
              buttonActive = active;
              selectedHeight = height;
              selectedWeight = weight;
              usesImperialUnits = imperial;
            },
          ),
        ),
      ),
    );

    // Inicialmente deve mostrar 'kg' no label do campo de peso
    expect(find.textContaining('kg'), findsWidgets);
    expect(find.textContaining('lbs'), findsNothing);

    // Tocar no botão para trocar para lbs
    final lbsToggle = find.text(S.current.lbsLabel);
    await tester.tap(lbsToggle);
    await tester.pumpAndSettle();

    // Agora deve mostrar 'lbs' no label do campo de peso
    expect(find.textContaining('lbs'), findsWidgets);
    expect(find.textContaining('kg'), findsNothing);
  });
}
