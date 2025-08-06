import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logging/logging.dart';

class SetStudentMacrosPage extends StatefulWidget {
  final String studentId;
  const SetStudentMacrosPage({super.key, required this.studentId});

  @override
  State<SetStudentMacrosPage> createState() => _SetStudentMacrosPageState();
}

class _SetStudentMacrosPageState extends State<SetStudentMacrosPage> {
  DateTime _startDate = DateTime.now();
  final log = Logger('SetStudentMacrosPage');
  final _carbsController = TextEditingController(text: '250');
  final _fatController = TextEditingController(text: '60');
  final _proteinController = TextEditingController(text: '120');

  int _calculatedCalories = 0;

  @override
  void initState() {
    super.initState();
    _calculateCalories();

    _carbsController.addListener(_calculateCalories);
    _fatController.addListener(_calculateCalories);
    _proteinController.addListener(_calculateCalories);
  }

  @override
  void dispose() {
    _carbsController.dispose();
    _fatController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    final carbs = int.tryParse(_carbsController.text) ?? 0;
    final fat = int.tryParse(_fatController.text) ?? 0;
    final protein = int.tryParse(_proteinController.text) ?? 0;

    setState(() {
      _calculatedCalories = (carbs * 4) + (fat * 9) + (protein * 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(S.of(context).setMacrosLabel)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _goToPreviousDay,
                  ),
                  InkWell(
                    onTap: _selectDate,
                    child: Row(
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd').format(_startDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _goToNextDay,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Glucides
              TextFormField(
                controller: _carbsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: S.of(context).carbsLabel,
                ),
              ),
              const SizedBox(height: 16),

              // Lipides
              TextFormField(
                controller: _fatController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: S.of(context).fatLabel,
                ),
              ),
              const SizedBox(height: 16),

              // Protéines
              TextFormField(
                controller: _proteinController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: S.of(context).proteinLabel,
                ),
              ),
              const SizedBox(height: 24),

              // Calories affichées
              Center(
                child: Text(
                  '${S.of(context).caloriesLabel}: $_calculatedCalories kcal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveMacros,
                  child: Text(S.of(context).buttonSaveLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToPreviousDay() {
    setState(() {
      _startDate = _startDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _startDate = _startDate.add(const Duration(days: 1));
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveMacros() async {
    try {
      final supabase = locator<SupabaseClient>();
      final json = {
        'user_id': widget.studentId,
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
        'calorie_goal': _calculatedCalories,
        'carb_goal': int.parse(_carbsController.text),
        'fat_goal': int.parse(_fatController.text),
        'protein_goal': int.parse(_proteinController.text),
      };

      await supabase
          .from('coach_macro_goals')
          .upsert(json, onConflict: 'user_id');

      if (!mounted) return;
      Navigator.pop(context);
    } catch (exception, stacktrace) {
      log.warning("Erreur lors de l'enregistrement des objectifs macro.");
      FirebaseCrashlytics.instance.recordError(exception, stacktrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Problème lors de l'enregistrement des objectifs macro.",
            ),
          ),
        );
      }
    }
  }
}
