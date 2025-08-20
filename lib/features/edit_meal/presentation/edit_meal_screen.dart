import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:opennutritracker/core/utils/custom_text_input_formatter.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/edit_meal/presentation/bloc/edit_meal_bloc.dart';
import 'package:opennutritracker/features/edit_meal/presentation/widgets/default_meal_image.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class EditMealScreen extends StatefulWidget {
  const EditMealScreen({super.key});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final log = Logger('EditMealScreen');
  late MealEntity _mealEntity;
  late DateTime _day;
  late IntakeTypeEntity _intakeTypeEntity;
  late bool _usesImperialUnits;

  late EditMealBloc _editMealBloc;

  final _nameTextController = TextEditingController();
  final _brandsTextController = TextEditingController();
  final _mealQuantityTextController = TextEditingController();
  final _servingQuantityTextController = TextEditingController();
  final _baseQuantityTextController = TextEditingController();
  final _kcalTextController = TextEditingController();
  final _carbsTextController = TextEditingController();
  final _fatTextController = TextEditingController();
  final _proteinTextController = TextEditingController();

  final _units = ['g', 'ml', 'g/ml'];
  String? selectedUnit;

  late List<ButtonSegment<String>> _mealUnitButtonSegment;

  @override
  void initState() {
    super.initState();
    // Initialize once, not during build.
    _editMealBloc = locator<EditMealBloc>();
    _editMealBloc.add(InitializeEditMealEvent());
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)?.settings.arguments as EditMealScreenArguments;
    _mealEntity = args.mealEntity;
    _day = args.day;
    _intakeTypeEntity = args.intakeTypeEntity;
    _usesImperialUnits = args.usesImperialUnits;

    _nameTextController.text = _mealEntity.name ?? "";
    _brandsTextController.text = _mealEntity.brands ?? "";
    _mealQuantityTextController.text = _mealEntity.mealQuantity ?? "";
    _servingQuantityTextController.text =
        _mealEntity.servingQuantity.toStringOrEmpty();
    _kcalTextController.text =
        _mealEntity.nutriments.energyKcal100.toStringOrEmpty();
    _carbsTextController.text =
        _mealEntity.nutriments.carbohydrates100.toStringOrEmpty();
    _fatTextController.text = _mealEntity.nutriments.fat100.toStringOrEmpty();
    _proteinTextController.text =
        _mealEntity.nutriments.proteins100.toStringOrEmpty();
    selectedUnit = _switchButtonUnit(_mealEntity.mealUnit);

    // Convert meal size to imperial units if necessary
    if (_usesImperialUnits) {
      _mealQuantityTextController.text = _convertToImperial(
          _mealQuantityTextController.text, _mealEntity.mealUnit ?? "0");
      _servingQuantityTextController.text = _convertToImperial(
          _servingQuantityTextController.text, _mealEntity.mealUnit ?? "0");
    }

    _mealUnitButtonSegment = [
      ButtonSegment(
        value: _units[0],
        label: Text(
            _usesImperialUnits ? S.of(context).ozUnit : S.of(context).gramUnit),
      ),
      ButtonSegment(
        value: _units[1],
        label: Text(_usesImperialUnits
            ? S.of(context).flOzUnit
            : S.of(context).milliliterUnit),
      ),
      ButtonSegment(
        value: _units[2],
        label: Text(S.of(context).gramMilliliterUnit),
      ),
    ];

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _brandsTextController.dispose();
    _mealQuantityTextController.dispose();
    _servingQuantityTextController.dispose();
    _baseQuantityTextController.dispose();
    _kcalTextController.dispose();
    _carbsTextController.dispose();
    _fatTextController.dispose();
    _proteinTextController.dispose();
    // Do not close _editMealBloc here if provided as a singleton by locator.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).editMealLabel),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: FilledButton(
                  onPressed: () => _onSavePressed(_usesImperialUnits),
                  child: Text(S.of(context).buttonSaveLabel)),
            )
          ],
        ),
        body: BlocBuilder<EditMealBloc, EditMealState>(
          bloc: _editMealBloc, 
          builder: (BuildContext context, EditMealState state) {
            if (state is EditMealLoadingState) {
              return _getLoadingContent();
            } else if (state is EditMealLoadedState) {
              return _getLoadedContent(state.usesImperialUnits);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _getLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getLoadedContent(bool usesImperialUnits) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
            child: ClipOval(
          child: CachedNetworkImage(
            cacheManager: locator<CacheManager>(),
            width: 120,
            height: 120,
            placeholder: (context, string) => const DefaultMealImage(),
            errorWidget: (context, exception, stacktrace) =>
                const DefaultMealImage(),
            fit: BoxFit.cover,
            imageUrl: _mealEntity.mainImageUrl ?? "",
          ),
        )),
        const SizedBox(height: 32),
        TextFormField(
          controller: _nameTextController,
          decoration: InputDecoration(
              labelText: S.of(context).mealNameLabel,
              border: const OutlineInputBorder()),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _brandsTextController,
          decoration: InputDecoration(
              labelText: S.of(context).mealBrandsLabel,
              border: const OutlineInputBorder()),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _mealQuantityTextController,
          decoration: InputDecoration(
              labelText: _usesImperialUnits
                  ? S.of(context).mealSizeLabelImperial
                  : S.of(context).mealSizeLabel,
              border: const OutlineInputBorder()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _servingQuantityTextController,
          inputFormatters: CustomTextInputFormatter.doubleOnly(),
          decoration: InputDecoration(
              labelText: _usesImperialUnits
                  ? S.of(context).servingSizeLabelImperial
                  : S.of(context).servingSizeLabelMetric,
              border: const OutlineInputBorder()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: _mealUnitButtonSegment,
          selected: {selectedUnit ?? _units[2]},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              selectedUnit = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 48),
        TextFormField(
          controller: _baseQuantityTextController,
          inputFormatters: CustomTextInputFormatter.doubleOnly(),
          decoration: InputDecoration(
              labelText: S.of(context).baseQuantityLabel,
              border: const OutlineInputBorder()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 48),
        
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _baseQuantityTextController,
          builder: (context, value, _) {
            final base = (value.text.isEmpty ? '100' : value.text) + _unitSuffixForSelected(context);
            return TextFormField(
              controller: _kcalTextController,
              inputFormatters: CustomTextInputFormatter.doubleOnly(),
              decoration: InputDecoration(
                  labelText: S.of(context).mealKcalLabel + base,
                  border: const OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            );
          },
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _baseQuantityTextController,
          builder: (context, value, _) {
            final base = (value.text.isEmpty ? '100' : value.text) + _unitSuffixForSelected(context);
            return TextFormField(
              controller: _carbsTextController,
              inputFormatters: CustomTextInputFormatter.doubleOnly(),
              decoration: InputDecoration(
                  labelText: S.of(context).mealCarbsLabel + base,
                  border: const OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            );
          },
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _baseQuantityTextController,
          builder: (context, value, _) {
            final base = (value.text.isEmpty ? '100' : value.text) + _unitSuffixForSelected(context);
            return TextFormField(
              controller: _fatTextController,
              inputFormatters: CustomTextInputFormatter.doubleOnly(),
              decoration: InputDecoration(
                  labelText: S.of(context).mealFatLabel + base,
                  border: const OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            );
          },
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _baseQuantityTextController,
          builder: (context, value, _) {
            final base = (value.text.isEmpty ? '100' : value.text) + _unitSuffixForSelected(context);
            return TextFormField(
              controller: _proteinTextController,
              inputFormatters: CustomTextInputFormatter.doubleOnly(),
              decoration: InputDecoration(
                  labelText: S.of(context).mealProteinLabel + base,
                  border: const OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            );
          },
        ),
      ],
    );
  }

  void _onSavePressed(bool usesImperialUnits) {
    try {
      // Convert meal size back to metric units if necessary
      final mealUnitForConversion = selectedUnit ?? _mealEntity.mealUnit ?? '0';
      final mealQuantity = usesImperialUnits
          ? _convertToMetric(_mealQuantityTextController.text, mealUnitForConversion)
          : _mealQuantityTextController.text;

      final newMealEntity = _editMealBloc.createNewMealEntity(
          _mealEntity,
          _nameTextController.text,
          _brandsTextController.text,
          mealQuantity,
          _servingQuantityTextController.text,
          _baseQuantityTextController.text,
          selectedUnit,
          _kcalTextController.text,
          _carbsTextController.text,
          _fatTextController.text,
          _proteinTextController.text);

      Navigator.of(context).pushNamedAndRemoveUntil(
          NavigationOptions.mealDetailRoute,
          ModalRoute.withName(NavigationOptions.addMealRoute),
          arguments: MealDetailScreenArguments(
              newMealEntity, _intakeTypeEntity, _day, usesImperialUnits));
    } catch (exception, stacktrace) {
      log.warning("Error while creating new meal entity");
      Sentry.captureException(exception, stackTrace: stacktrace);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.of(context).errorMealSave)));
    }
  }

  String? _switchButtonUnit(String? unit) {
    if (!_units.contains(unit)) {
      return _units[2]; // Default to g/ml
    }
    return unit;
  }

  String _unitSuffixForSelected(BuildContext context) {
    final u = selectedUnit ?? _units[2];
    if (u == 'g') {
      return _usesImperialUnits ? ' ' + S.of(context).ozUnit : ' ' + S.of(context).gramUnit;
    } else if (u == 'ml') {
      return _usesImperialUnits ? ' ' + S.of(context).flOzUnit : ' ' + S.of(context).milliliterUnit;
    }
    return ' ' + S.of(context).gramMilliliterUnit;
  }

  String _convertToImperial(String value, String unit) {
    final double quantityValue = double.tryParse(value) ?? 0.0;
    switch (unit) {
      case 'g':
        return (UnitCalc.gToOz(quantityValue)).toStringAsFixed(2);
      case 'ml':
        return (UnitCalc.mlToFlOz(quantityValue)).toStringAsFixed(2);
      default:
        return value;
    }
  }

  String _convertToMetric(String value, String unit) {
    final double quantityValue = double.tryParse(value) ?? 0.0;
    switch (unit) {
      case 'g':
        return (UnitCalc.ozToG(quantityValue)).toStringAsFixed(2);
      case 'ml':
        return (UnitCalc.flOzToMl(quantityValue)).toStringAsFixed(2);
      default:
        return value;
    }
  }
}

class EditMealScreenArguments {
  final DateTime day;
  final MealEntity mealEntity;
  final IntakeTypeEntity intakeTypeEntity;
  final bool usesImperialUnits;

  EditMealScreenArguments(
      this.day, this.mealEntity, this.intakeTypeEntity, this.usesImperialUnits);
}
