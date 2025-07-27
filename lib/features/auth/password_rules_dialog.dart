import 'package:flutter/material.dart';
import 'package:opennutritracker/generated/l10n.dart';

class PasswordRulesDialog extends StatelessWidget {
  final bool validMinLength;
  final bool validUppercase;
  final bool validLowercase;
  final bool validDigit;
  final bool validSpecial;

  const PasswordRulesDialog({
    super.key,
    required this.validMinLength,
    required this.validUppercase,
    required this.validLowercase,
    required this.validDigit,
    required this.validSpecial,
  });

  Color _color(BuildContext context, bool valid) =>
      valid ? Colors.green : Theme.of(context).colorScheme.onSurface;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).resetPasswordNewLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rule(context, S.of(context).passwordMinLength, validMinLength),
          _rule(context, S.of(context).passwordUppercase, validUppercase),
          _rule(context, S.of(context).passwordLowercase, validLowercase),
          _rule(context, S.of(context).passwordDigit, validDigit),
          _rule(context, S.of(context).passwordSpecialChar, validSpecial),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogOKLabel),
        ),
      ],
    );
  }

  Widget _rule(BuildContext context, String text, bool valid) =>
      Row(
        children: [
          Icon(Icons.check, color: _color(context, valid), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: _color(context, valid)),
            ),
          ),
        ],
      );
}
