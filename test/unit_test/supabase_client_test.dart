import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/features/sync/supabase_client.dart';

void main() {
  late final SupabaseClient mockSupabase;
  late final MockSupabaseHttpClient mockHttpClient;
  late final SupabaseTrackedDayService trackedDayService;

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();

    // Inject mockHttpClient properly
    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );

    trackedDayService = SupabaseTrackedDayService(client: mockSupabase);
  });

  tearDown(() async {
    // Reset mock data between tests
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  test('inserting a single tracked day works', () async {
    final now = DateTime.now();

    await trackedDayService.upsertTrackedDay({
      'day': now.toIso8601String(),
      'calories': 2000,
      'carbs': 300,
      'proteins': 100,
      'fats': 70,
    });

    final result = await mockSupabase.from('tracked_days').select();
    expect(result.length, 1);
    expect(result.first, {
      'day': now.toIso8601String(),
      'calories': 2000,
      'carbs': 300,
      'proteins': 100,
      'fats': 70,
    });
  });

  test('bulk upsert of tracked days works', () async {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    await trackedDayService.upsertTrackedDays([
      {
        'day': yesterday.toIso8601String(),
        'calories': 1800,
        'carbs': 250,
        'proteins': 90,
        'fats': 60,
      },
      {
        'day': today.toIso8601String(),
        'calories': 2100,
        'carbs': 320,
        'proteins': 110,
        'fats': 80,
      },
    ]);

    final result = await mockSupabase.from('tracked_days').select();
    expect(result.length, 2);
    expect(
        result,
        containsAll([
          {
            'day': yesterday.toIso8601String(),
            'calories': 1800,
            'carbs': 250,
            'proteins': 90,
            'fats': 60,
          },
          {
            'day': today.toIso8601String(),
            'calories': 2100,
            'carbs': 320,
            'proteins': 110,
            'fats': 80,
          },
        ]));
  });

  test('bulk upsert with empty list does nothing', () async {
    await trackedDayService.upsertTrackedDays([]);

    final result = await mockSupabase.from('tracked_days').select();
    expect(result, isEmpty);
  });

  test('deleting a tracked day works', () async {
    final date = DateTime.now();

    // Insert a day first
    await trackedDayService.upsertTrackedDay({
      'day': date.toIso8601String(),
      'calories': 2000,
      'carbs': 300,
      'proteins': 100,
      'fats': 70,
    });

    // Delete it
    await trackedDayService.deleteTrackedDay(date);

    final result = await mockSupabase.from('tracked_days').select();
    expect(result, isEmpty);
  });
}
