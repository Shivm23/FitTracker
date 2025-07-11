import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/validation/food_name_validator.dart';


void main() {
  group('FoodNameValidator', () {
    test('falha quando o nome é só números', () {
      expect(FoodNameValidator.isValid('123456'), isFalse);
    });
    test('falha quando o nome é só símbolos', () {
      expect(FoodNameValidator.isValid('@#\$%^'), isFalse);
    });
    test('sucesso quando há pelo menos uma letra', () {
      expect(FoodNameValidator.isValid('Maçã123'), isTrue);
    });
    test('falha quando string vazia', () {
      expect(FoodNameValidator.isValid(''), isFalse);
    });
  });
}
