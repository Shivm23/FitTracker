import 'package:flutter/material.dart';
import 'password_utils.dart';

String? validatePassword(BuildContext context, String? value) =>
    PasswordUtils.validate(context, value);
