import 'package:flutter/material.dart';
import 'package:opennutritracker/features/add_weight/presentation/bloc/weight_bloc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/formatters/one_decimal_place_formatter.dart';

class EditableTextWidget extends StatefulWidget {
  final String initialValue;
  final bool disabledEnter;

  const EditableTextWidget(
      {super.key, required this.initialValue, required this.disabledEnter});

  @override
  State<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  bool _isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late WeightBloc _weightBloc;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _weightBloc = locator<WeightBloc>();
  }

  @override
  void didUpdateWidget(covariant EditableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      if (!_isEditing) {
        _textController.text = widget.initialValue;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveAndSwitchToDisplayMode(String selectedWeight) {
    if (!mounted) return;

    String normalizedValue = selectedWeight.replaceAll(',', '.');

    setState(() {
      _isEditing = false;
      _textController.text = selectedWeight;
    });

    if (normalizedValue.isEmpty) {
      return;
    }

    _weightBloc.add(WeightSet(double.parse(normalizedValue)));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle effectiveTextStyle =
        theme.textTheme.headlineMedium ?? const TextStyle();
    final String weightUnit = " kg";

    return SizedBox(
        width: 135.0,
        child: _isEditing && !widget.disabledEnter
            ? TextFormField(
                controller: _textController,
                style: effectiveTextStyle,
                textAlign: TextAlign.center,
                focusNode: _focusNode,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: .5, vertical: 0.0),
                  border: InputBorder.none,
                  isDense: true,
                  suffixText: weightUnit,
                ),
                inputFormatters: [
                  OneDecimalPlaceFormatter(maxValue: _weightBloc.maxWeight),
                ],
                onTapOutside: (event) =>
                    _saveAndSwitchToDisplayMode(_textController.text),
                onFieldSubmitted: (newValue) {
                  _saveAndSwitchToDisplayMode(newValue);
                })
            : GestureDetector(
                onTap: () {
                  setState(() => _isEditing = true);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _focusNode.requestFocus();
                  });
                },
                child: Text(
                  _textController.text + weightUnit,
                  textAlign: TextAlign.center,
                  style: effectiveTextStyle,
                )));
  }
}
