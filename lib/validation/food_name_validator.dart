class FoodNameValidator {
  static bool isValid(String name) {
    if (name.isEmpty) return false;

    return RegExp(r'[A-Za-z]').hasMatch(name);
  }
}
