import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class EditDialog extends StatefulWidget {
  final IntakeEntity intakeEntity;
  final bool usesImperialUnits;

  const EditDialog(
      {super.key, required this.intakeEntity, required this.usesImperialUnits});

  @override
  State<StatefulWidget> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController amountEditingController;

  @override
  void initState() {
    super.initState();
    final intakeUnit = widget.intakeEntity.unit;
    // If intake is per serving, keep the raw serving count without conversion
    if (intakeUnit.toLowerCase() == 'serving') {
      amountEditingController = TextEditingController(
        text: widget.intakeEntity.amount.toStringAsFixed(2),
      );
    } else {
      double initialAmount = _convertValue(
        widget.intakeEntity.amount,
        widget.intakeEntity.meal.mealUnit,
      );
      amountEditingController =
          TextEditingController(text: initialAmount.toStringAsFixed(2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).editItemDialogTitle),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          controller: amountEditingController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: S.of(context).quantityLabel,
              // If serving, display serving label; otherwise convert g/ml to imperial if needed
              suffixText: widget.intakeEntity.unit.toLowerCase() == 'serving'
                  ? S.of(context).servingLabel
                  : _convertUnit(widget.intakeEntity.meal.mealUnit ?? '')),
        )
      ]),
      actions: [
        TextButton(
            onPressed: () {
              double newAmount =
                  double.parse(amountEditingController.text.replaceAll(',', '.'));
              if (widget.intakeEntity.unit.toLowerCase() == 'serving') {
                // Persist servings as-is
                Navigator.of(context).pop(newAmount);
              } else {
                Navigator.of(context).pop(_convertBackToMetricValue(
                    newAmount, widget.intakeEntity.meal.mealUnit));
              }
            },
            child: Text(S.of(context).dialogOKLabel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).dialogCancelLabel))
      ],
    );
  }

  double _convertValue(double value, String? unit) {
    switch (unit) {
      case 'g':
        return widget.usesImperialUnits ? UnitCalc.gToOz(value) : value;
      case 'ml':
        return widget.usesImperialUnits ? UnitCalc.mlToFlOz(value) : value;
      default:
        return value;
    }
  }

  double _convertBackToMetricValue(double value, String? unit) {
    switch (unit) {
      case 'g':
        return widget.usesImperialUnits ? UnitCalc.ozToG(value) : value;
      case 'ml':
        return widget.usesImperialUnits ? UnitCalc.flOzToMl(value) : value;
      default:
        return value;
    }
  }

  String _convertUnit(String unit) {
    switch (unit) {
      case 'g':
        return widget.usesImperialUnits ? 'oz' : 'g';
      case 'ml':
        return widget.usesImperialUnits ? 'fl.oz' : 'ml';
      default:
        return unit;
    }
  }
}
