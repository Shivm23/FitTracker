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
import 'package:opennutritracker/validation/food_name_validator.dart';
import 'package:opennutritracker/features/edit_meal/presentation/bloc/edit_meal_bloc.dart';
import 'package:opennutritracker/features/edit_meal/presentation/widgets/default_meal_image.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class EditMealScreen extends StatefulWidget {
  const EditMealScreen({Key? key}) : super(key: key);

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
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
  late String selectedUnit;
  late List<ButtonSegment<String>> _mealUnitButtonSegment;

  String baseQuantity = '100';
  String baseQuantityUnit = ' g/ml';

  @override
  void initState() {
    super.initState();
    _editMealBloc = locator<EditMealBloc>();
    _baseQuantityTextController.addListener(() {
      setState(() { baseQuantity = _baseQuantityTextController.text; });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as EditMealScreenArguments;
    _mealEntity = args.mealEntity;
    _day = args.day;
    _intakeTypeEntity = args.intakeTypeEntity;
    _usesImperialUnits = args.usesImperialUnits;

    _nameTextController.text = _mealEntity.name ?? '';
    _brandsTextController.text = _mealEntity.brands ?? '';
    _mealQuantityTextController.text = _mealEntity.mealQuantity ?? '';
    _servingQuantityTextController.text = _mealEntity.servingQuantity.toStringOrEmpty();
    _kcalTextController.text = _mealEntity.nutriments.energyKcal100.toStringOrEmpty();
    _carbsTextController.text = _mealEntity.nutriments.carbohydrates100.toStringOrEmpty();
    _fatTextController.text = _mealEntity.nutriments.fat100.toStringOrEmpty();
    _proteinTextController.text = _mealEntity.nutriments.proteins100.toStringOrEmpty();
    selectedUnit = _switchButtonUnit(_mealEntity.mealUnit);

    if (_usesImperialUnits) {
      _mealQuantityTextController.text =
        _convertToImperial(_mealQuantityTextController.text, _mealEntity.mealUnit ?? 'g');
      _servingQuantityTextController.text =
        _convertToImperial(_servingQuantityTextController.text, _mealEntity.mealUnit ?? 'g');
    }

    _mealUnitButtonSegment = [
      ButtonSegment(value: _units[0], label: Text(_usesImperialUnits ? S.of(context).ozUnit : S.of(context).gramUnit)),
      ButtonSegment(value: _units[1], label: Text(_usesImperialUnits ? S.of(context).flOzUnit : S.of(context).milliliterUnit)),
      ButtonSegment(value: _units[2], label: Text(S.of(context).gramMilliliterUnit)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).editMealLabel),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16,0,16,0),
              child: FilledButton(
                onPressed: () => _onSavePressed(),
                child: Text(S.of(context).buttonSaveLabel),
              ),
            ),
          ],
        ),
        body: BlocBuilder<EditMealBloc, EditMealState>(
          bloc: _editMealBloc..add(InitializeEditMealEvent()),
          builder: (context, state) {
            if (state is EditMealLoadingState) return _getLoadingContent();
            if (state is EditMealLoadedState) return _getLoadedContent(state.usesImperialUnits);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _getLoadingContent() => const Center(child: CircularProgressIndicator());

  Widget _getLoadedContent(bool usesImperialUnits) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ClipOval(
              child: CachedNetworkImage(
                cacheManager: locator<CacheManager>(),
                width: 120, height: 120,
                placeholder: (ctx,url)=>const DefaultMealImage(),
                errorWidget: (ctx,_,__)=>const DefaultMealImage(),
                fit: BoxFit.cover,
                imageUrl: _mealEntity.mainImageUrl ?? '',
              ),
            ),
          ),
          const SizedBox(height:32),
          TextFormField(
            controller: _nameTextController,
            decoration: InputDecoration(labelText: S.of(context).mealNameLabel, border: OutlineInputBorder()),
            validator: (v){ if(!FoodNameValidator.isValid(v??'')) return 'O nome deve conter pelo menos uma letra'; return null; },
          ),
          const SizedBox(height:16),
          TextFormField(controller: _brandsTextController, decoration: InputDecoration(labelText: S.of(context).mealBrandsLabel, border: OutlineInputBorder())),
          const SizedBox(height:32),
          TextFormField(controller: _mealQuantityTextController, decoration: InputDecoration(labelText: usesImperialUnits?S.of(context).mealSizeLabelImperial:S.of(context).mealSizeLabel, border:OutlineInputBorder()), keyboardType: TextInputType.numberWithOptions(decimal:true)),
          const SizedBox(height:16),
          TextFormField(controller: _servingQuantityTextController,inputFormatters:CustomTextInputFormatter.doubleOnly(),decoration:InputDecoration(labelText:usesImperialUnits?S.of(context).servingSizeLabelImperial:S.of(context).servingSizeLabelMetric,border:OutlineInputBorder()),keyboardType:TextInputType.numberWithOptions(decimal:true)),
          const SizedBox(height:16),
          SegmentedButton<String>(segments:_mealUnitButtonSegment,selected:{selectedUnit},onSelectionChanged:(s)=>setState(()=>selectedUnit=s.first)),
          const SizedBox(height:48),
          TextFormField(controller:_baseQuantityTextController,inputFormatters:CustomTextInputFormatter.doubleOnly(),decoration:InputDecoration(labelText:S.of(context).baseQuantityLabel,border:OutlineInputBorder()),keyboardType:TextInputType.number),
          const SizedBox(height:48),
          TextFormField(controller:_kcalTextController,inputFormatters:CustomTextInputFormatter.doubleOnly(),decoration:InputDecoration(labelText:S.of(context).mealKcalLabel+baseQuantity+baseQuantityUnit,border:OutlineInputBorder()),keyboardType:TextInputType.numberWithOptions(decimal:true)),
          const SizedBox(height:16),
          TextFormField(controller:_carbsTextController,inputFormatters:CustomTextInputFormatter.doubleOnly(),decoration:InputDecoration(labelText:S.of(context).mealCarbsLabel+baseQuantity+baseQuantityUnit,border:OutlineInputBorder()),keyboardType:TextInputType.numberWithOptions(decimal:true)),
          const SizedBox(height:16),
          TextFormField(controller:_fatTextController,inputFormatters:CustomTextInputFormatter.doubleOnly(),decoration:InputDecoration(labelText:S.of(context).mealFatLabel+baseQuantity+baseQuantityUnit,border:OutlineInputBorder()),keyboardType:TextInputType.numberWithOptions(decimal:true)),
          const SizedBox(height:16),
          TextFormField(controller:_proteinTextController,inputFormatters:CustomTextInputFormatter.doubleOnly(),decoration:InputDecoration(labelText:S.of(context).mealProteinLabel+baseQuantity+baseQuantityUnit,border:OutlineInputBorder()),keyboardType:TextInputType.numberWithOptions(decimal:true)),
        ],
      ),
    );
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;
    try {
      final mealQty = _usesImperialUnits?_convertToMetric(_mealQuantityTextController.text,_mealEntity.mealUnit??'g'):_mealQuantityTextController.text;
      final newMeal = _editMealBloc.createNewMealEntity(_mealEntity,_nameTextController.text,_brandsTextController.text,mealQty,_servingQuantityTextController.text,_baseQuantityTextController.text,selectedUnit,_kcalTextController.text,_carbsTextController.text,_fatTextController.text,_proteinTextController.text);
      Navigator.of(context).pushNamedAndRemoveUntil(NavigationOptions.mealDetailRoute,ModalRoute.withName(NavigationOptions.addMealRoute),arguments:MealDetailScreenArguments(newMeal,_intakeTypeEntity,_day,_usesImperialUnits));
    } catch(e,st){
      log.warning('Error while creating new meal entity');
      Sentry.captureException(e,stackTrace:st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(S.of(context).errorMealSave)));
    }
  }

  String _switchButtonUnit(String? unit)=>_units.contains(unit)?unit!:_units[2];

  String _convertToImperial(String value,String unit){
    final q=double.tryParse(value)??0.0;
    return unit=='g'?UnitCalc.gToOz(q).toStringAsFixed(2):unit=='ml'?UnitCalc.mlToFlOz(q).toStringAsFixed(2):value;
  }

  String _convertToMetric(String value,String unit){
    final q=double.tryParse(value)??0.0;
    return unit=='g'?UnitCalc.ozToG(q).toStringAsFixed(2):unit=='ml'?UnitCalc.flOzToMl(q).toStringAsFixed(2):value;
  }
}

class EditMealScreenArguments {
  final DateTime day;
  final MealEntity mealEntity;
  final IntakeTypeEntity intakeTypeEntity;
  final bool usesImperialUnits;
  EditMealScreenArguments(this.day,this.mealEntity,this.intakeTypeEntity,this.usesImperialUnits);
}
