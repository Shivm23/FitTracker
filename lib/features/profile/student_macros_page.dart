import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/home/presentation/widgets/macro_nutriments_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'set_student_macros_page.dart';

class StudentMacrosPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const StudentMacrosPage({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentMacrosPage> createState() => _StudentMacrosPageState();
}

enum MacroType { calories, carbs, fat, protein }

enum TimeRange { week, month, threeMonths, sixMonths, year }

class _StudentMacrosPageState extends State<StudentMacrosPage> {
  late Future<Map<String, Map<String, dynamic>>> _macrosFuture;
  Map<String, Map<String, dynamic>> _allMacros = {};
  DateTime _selectedDate = DateTime.now();
  MacroType _selectedMacro = MacroType.calories;
  TimeRange _selectedRange = TimeRange.month;

  @override
  void initState() {
    super.initState();
    _macrosFuture = _fetchMacros();
  }

  Future<Map<String, Map<String, dynamic>>> _fetchMacros() async {
    final supabase = locator<SupabaseClient>();

    final now = DateTime.now();
    final startDate = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 365)));
    final endDate = DateFormat('yyyy-MM-dd').format(now);

    final response = await supabase
        .from('tracked_days')
        .select(
            'day, calorieGoal, caloriesTracked, carbsGoal, carbsTracked, fatGoal, fatTracked, proteinGoal, proteinTracked')
        .eq('user_id', widget.studentId)
        .gte('day', startDate)
        .lte('day', endDate)
        .order('day');

    return {
      for (final Map<String, dynamic> item in response)
        item['day'] as String: item
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSetMacrosPage,
        icon: const Icon(Icons.edit_outlined),
        label: Text(S.of(context).setMacrosLabel),
      ),
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: _macrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('${S.of(context).errorPrefix} ${snapshot.error}'),
            );
          }

          if (snapshot.hasData) {
            _allMacros = snapshot.data!;
          }

          final dayKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
          final data = _allMacros[dayKey];

          final double calorieGoal = (data?['calorieGoal'] ?? 0).toDouble();
          final double caloriesTracked =
              (data?['caloriesTracked'] ?? 0).toDouble();
          final double carbsGoal = (data?['carbsGoal'] ?? 0).toDouble();
          final double carbsTracked = (data?['carbsTracked'] ?? 0).toDouble();
          final double fatGoal = (data?['fatGoal'] ?? 0).toDouble();
          final double fatTracked = (data?['fatTracked'] ?? 0).toDouble();
          final double proteinGoal = (data?['proteinGoal'] ?? 0).toDouble();
          final double proteinTracked =
              (data?['proteinTracked'] ?? 0).toDouble();

          final double kcalLeft = calorieGoal - caloriesTracked;
          final double gaugeValue = calorieGoal == 0
              ? 0
              : (caloriesTracked / calorieGoal).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Navigation toujours visible
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _goToPreviousDay,
                        ),
                        InkWell(
                          onTap: _selectDate,
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _goToNextDay,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Si pas de données pour ce jour
                    if (data == null)
                      Text(S.of(context).noDataToday)
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.keyboard_arrow_up_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              Text('${caloriesTracked.toInt()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              Text(S.of(context).suppliedLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                            ],
                          ),
                          CircularPercentIndicator(
                            radius: 90.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: gaugeValue,
                            arcType: ArcType.FULL,
                            progressColor:
                                Theme.of(context).colorScheme.primary,
                            arcBackgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(50),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedFlipCounter(
                                  duration: const Duration(milliseconds: 1000),
                                  value: kcalLeft.clamp(0, calorieGoal).toInt(),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          letterSpacing: -1),
                                ),
                                Text(
                                  S.of(context).kcalLeftLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                )
                              ],
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          Column(
                            children: [
                              Icon(Icons.keyboard_arrow_down_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              Text('0',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              Text(S.of(context).burnedLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                            ],
                          ),
                        ],
                      ),
                      MacroNutrientsView(
                        totalCarbsIntake: carbsTracked,
                        totalFatsIntake: fatTracked,
                        totalProteinsIntake: proteinTracked,
                        totalCarbsGoal: carbsGoal,
                        totalFatsGoal: fatGoal,
                        totalProteinsGoal: proteinGoal,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<MacroType>(
                          value: _selectedMacro,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedMacro = value;
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: MacroType.calories,
                              child: Text(S.of(context).caloriesLabel),
                            ),
                            DropdownMenuItem(
                              value: MacroType.carbs,
                              child: Text(S.of(context).carbsLabel),
                            ),
                            DropdownMenuItem(
                              value: MacroType.fat,
                              child: Text(S.of(context).fatLabel),
                            ),
                            DropdownMenuItem(
                              value: MacroType.protein,
                              child: Text(S.of(context).proteinLabel),
                            ),
                          ],
                        ),
                        DropdownButton<TimeRange>(
                          value: _selectedRange,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedRange = value;
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: TimeRange.week,
                              child: Text('1W'),
                            ),
                            DropdownMenuItem(
                              value: TimeRange.month,
                              child: Text('1M'),
                            ),
                            DropdownMenuItem(
                              value: TimeRange.threeMonths,
                              child: Text('3M'),
                            ),
                            DropdownMenuItem(
                              value: TimeRange.sixMonths,
                              child: Text('6M'),
                            ),
                            DropdownMenuItem(
                              value: TimeRange.year,
                              child: Text('1Y'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(),
                        series: <ScatterSeries<_MacroPoint, DateTime>>[
                          ScatterSeries<_MacroPoint, DateTime>(
                            dataSource: _getMacroPoints(_selectedMacro)
                                .where((e) => e.value != null)
                                .toList(),
                            xValueMapper: (p, _) => p.date,
                            yValueMapper: (p, _) => p.value,
                            markerSettings: const MarkerSettings(
                              isVisible: true,
                              width: 8,
                              height: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _openSetMacrosPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetStudentMacrosPage(studentId: widget.studentId),
      ),
    );
  }

  List<_MacroPoint> _getMacroPoints(MacroType type) {
    final now = DateTime.now();
    final start = _rangeStart(now);
    final List<_MacroPoint> points = [];

    for (var day = start;
        !day.isAfter(now);
        day = day.add(const Duration(days: 1))) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      final data = _allMacros[key];

      double? value;
      if (data != null) {
        switch (type) {
          case MacroType.calories:
            value = (data['caloriesTracked'] as num?)?.toDouble();
            break;
          case MacroType.carbs:
            value = (data['carbsTracked'] as num?)?.toDouble();
            break;
          case MacroType.fat:
            value = (data['fatTracked'] as num?)?.toDouble();
            break;
          case MacroType.protein:
            value = (data['proteinTracked'] as num?)?.toDouble();
            break;
        }
      }

      // Ajoute la valeur (null s'il n'y a pas de données)
      points.add(_MacroPoint(day, value));
    }

    return points;
  }

  DateTime _rangeStart(DateTime now) {
    switch (_selectedRange) {
      case TimeRange.week:
        return now.subtract(const Duration(days: 7));
      case TimeRange.month:
        return now.subtract(const Duration(days: 30));
      case TimeRange.threeMonths:
        return now.subtract(const Duration(days: 90));
      case TimeRange.sixMonths:
        return now.subtract(const Duration(days: 180));
      case TimeRange.year:
        return now.subtract(const Duration(days: 365));
    }
  }
}

class _MacroPoint {
  final DateTime date;
  final double? value; // Nullable pour gérer les jours sans données

  _MacroPoint(this.date, this.value);
}
