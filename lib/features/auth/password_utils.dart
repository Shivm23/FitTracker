import 'package:flutter/material.dart';
import 'package:opennutritracker/generated/l10n.dart';

/// Utility helpers and validation rules for user passwords.
class PasswordUtils {
  static const int minLength = 8;
  static final RegExp _uppercase = RegExp(r'[A-Z]');
  static final RegExp _lowercase = RegExp(r'[a-z]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static final RegExp _special = RegExp(r'[!@#\\$%^&*(),.?":{}|<>]');

  static bool hasMinLength(String v) => v.length >= minLength;
  static bool hasUppercase(String v) => _uppercase.hasMatch(v);
  static bool hasLowercase(String v) => _lowercase.hasMatch(v);
  static bool hasDigit(String v) => _digit.hasMatch(v);
  static bool hasSpecial(String v) => _special.hasMatch(v);

  /// Validate [value] against password rules.
  static String? validate(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).passwordRequired;
    }
    if (!hasMinLength(value)) {
      return S.of(context).passwordMinLength;
    }
    if (!hasUppercase(value)) {
      return S.of(context).passwordUppercase;
    }
    if (!hasLowercase(value)) {
      return S.of(context).passwordLowercase;
    }
    if (!hasDigit(value)) {
      return S.of(context).passwordDigit;
    }
    if (!hasSpecial(value)) {
      return S.of(context).passwordSpecialChar;
    }
    return null;
  }
}
