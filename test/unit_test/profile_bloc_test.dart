import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';

void main() {
  group('UnitCalc weight and unit conversions', () {
    test('kgToLbs e lbsToKg são operações inversas', () {
      expect(UnitCalc.kgToLbs(0), closeTo(0, 0.01));
      expect(UnitCalc.kgToLbs(1), closeTo(2.20, 0.01));
      expect(UnitCalc.lbsToKg(0), closeTo(0, 0.01));
      expect(UnitCalc.lbsToKg(2.20462), closeTo(1, 0.01));
    });
  });
}
