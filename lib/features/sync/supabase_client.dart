import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class SupabaseTrackedDayService {
  final SupabaseClient _client;
  final _log = Logger('DatabaseClient');

  SupabaseTrackedDayService({SupabaseClient? client})
      : _client = client ?? locator<SupabaseClient>();

  /// Upserts a single tracked day.
  /// Logs any exception that occurs during the operation.
  Future<void> upsertTrackedDay(Map<String, dynamic> json) async {
    try {
      await _client.from('tracked_days').upsert(json, onConflict: 'day');
    } catch (e, stackTrace) {
      _log.severe('Failed to upsert tracked day: $e', e, stackTrace);
    }
  }

  /// Upserts multiple tracked days in bulk.
  /// If the list is empty, the function exits early.
  /// Logs any exception that occurs during the operation.
  Future<void> upsertTrackedDays(List<Map<String, dynamic>> days) async {
    if (days.isEmpty) return;
    try {
      await _client.from('tracked_days').upsert(days, onConflict: 'day');
    } catch (e, stackTrace) {
      _log.severe('Failed to upsert tracked days: $e', e, stackTrace);
    }
  }

  /// Deletes a tracked day based on the provided date.
  /// Logs any exception that occurs during the operation.
  Future<void> deleteTrackedDay(DateTime day) async {
    final iso = day.toIso8601String();
    try {
      await _client.from('tracked_days').delete().eq('day', iso);
    } catch (e, stackTrace) {
      _log.severe('Failed to delete tracked day: $e', e, stackTrace);
    }
  }
}
