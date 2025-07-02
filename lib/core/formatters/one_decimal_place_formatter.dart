import 'package:flutter/services.dart';

class OneDecimalPlaceFormatter extends TextInputFormatter {
  final double maxValue;

  // Regex to allow numbers with at most one decimal place (dot or comma).
  // Allows an empty string, whole numbers, numbers followed by a dot/comma,
  // or numbers followed by a dot/comma and a single digit.
  final RegExp _regExp = RegExp(r'^\d*([.,]\d?)?$');

  OneDecimalPlaceFormatter({required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value is empty (e.g., user erases everything), accept it.
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // If the new value does not match the basic format (e.g. "1.23", "abc"), revert.
    if (!_regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    // At this point, the format is valid (0 or 1 decimal place).
    // Now, check against maxValue if the text is a parsable number.
    final String parsableText = newValue.text.replaceAll(',', '.');
    final double? currentNumericValue = double.tryParse(parsableText);

    if (currentNumericValue != null) {
      if (currentNumericValue > maxValue) {
        // If current value exceeds maxValue, clamp it.
        // Format maxValue to string: "150" if maxValue is 150.0, "150.5" if maxValue is 150.5
        String clampedText = (maxValue == maxValue.truncateToDouble())
            ? maxValue.truncate().toString()
            : maxValue.toStringAsFixed(1);

        return TextEditingValue(
          text: clampedText,
          selection: TextSelection.collapsed(offset: clampedText.length),
        );
      }
    }
    // If format is valid and (value is not parsable yet (e.g. "123.") or value <= maxValue)
    return newValue;
  }
}
