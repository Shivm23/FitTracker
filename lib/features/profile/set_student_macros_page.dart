import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
  final _kcalController = TextEditingController(text: '2000');
  final _carbsController = TextEditingController(text: '250');
  final _fatController = TextEditingController(text: '60');
  final _proteinController = TextEditingController(text: '120');

  @override
  void dispose() {
    _kcalController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).setMacrosLabel),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            TextFormField(
              controller: _kcalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: S.of(context).caloriesLabel,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: S.of(context).carbsLabel,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: S.of(context).fatLabel,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: S.of(context).proteinLabel,
              ),
            ),
            const Spacer(),
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
        'calorie_goal': int.parse(_kcalController.text),
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
      Sentry.captureException(exception, stackTrace: stacktrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Problème lors de l'enregistrement des objectifs macro.")),
        );
      }
    }
  }
}
