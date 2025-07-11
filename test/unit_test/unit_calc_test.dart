import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:flutter/material.dart';

void main() {
  group('UnitCalc weight and unit conversions', () {
    test('kgToLbs and lbsToKg are inverse operations', () {
      expect(UnitCalc.kgToLbs(0), closeTo(0, 0.01));
      expect(UnitCalc.kgToLbs(1), closeTo(2.20, 0.01));
      expect(UnitCalc.lbsToKg(0), closeTo(0, 0.01));
      expect(UnitCalc.lbsToKg(2.20462), closeTo(1, 0.01));
    });

    test('gToOz and ozToG are inverse operations', () {
      expect(UnitCalc.gToOz(0), closeTo(0, 0.01));
      expect(UnitCalc.gToOz(100), closeTo(3.53, 0.01));
      expect(UnitCalc.ozToG(0), closeTo(0, 0.01));
      expect(UnitCalc.ozToG(3.5274), closeTo(100, 0.1));
    });

    test('mlToFlOz and flOzToMl are inverse operations', () {
      expect(UnitCalc.mlToFlOz(0), closeTo(0, 0.01));
      expect(UnitCalc.mlToFlOz(100), closeTo(3.38, 0.01));
      expect(UnitCalc.flOzToMl(0), closeTo(0, 0.01));
      expect(UnitCalc.flOzToMl(3.3814), closeTo(100, 0.1));
    });

    test('metricToImperialValue and imperialToMetricValue for g/oz', () {
      expect(UnitCalc.metricToImperialValue(100, 'g'),
          closeTo(UnitCalc.gToOz(100), 0.01));
      expect(UnitCalc.imperialToMetricValue(3.5274, 'oz'), closeTo(100, 0.1));
    });

    test('metricToImperialValue and imperialToMetricValue for ml/fl oz', () {
      expect(UnitCalc.metricToImperialValue(100, 'ml'),
          closeTo(UnitCalc.mlToFlOz(100), 0.01));
      expect(
          UnitCalc.imperialToMetricValue(3.3814, 'fl oz'), closeTo(100, 0.1));
    });
  });
}
