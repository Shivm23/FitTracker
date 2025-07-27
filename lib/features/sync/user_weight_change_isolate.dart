import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/data_source/user_weight_dbo.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/sync/change_isolate.dart';
import 'package:opennutritracker/features/sync/supabase_client.dart';

/// Watches a [UserWeightDbo] box and synchronizes modified weights
/// with Supabase as soon as a connection is available.
class UserWeightChangeIsolate extends ChangeIsolate<DateTime> {
  final SupabaseUserWeightService _service;
  final Connectivity _connectivity;
  final int batchSize;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _syncing = false;
  final Logger _log = Logger('UserWeightChangeIsolate');

  UserWeightChangeIsolate(
    Box<UserWeightDbo> box, {
    SupabaseUserWeightService? service,
    Connectivity? connectivity,
    this.batchSize = 20,
  })  : _service = service ?? SupabaseUserWeightService(),
        _connectivity = connectivity ?? locator<Connectivity>(),
        super(
          box: box,
          extractor: (event) {
            final value = event.value;
            if (value is UserWeightDbo) return value.date;
            return null;
          },
          onItemCollected: null,
        );

  /// Convenient proxy to get the pending weight dates.
  Future<List<DateTime>> getModifiedWeights() => getItems();

  /* ---------- Lifecycle ---------- */

  @override
  Future<void> start() async {
    _log.info('Starting UserWeightChangeIsolate...');
    onItemCollected ??= _attemptSync;

    await super.start();
    _log.fine('ChangeIsolate started.');

    await _attemptSync();

    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _log.fine('Connectivity listener started.');
  }

  @override
  Future<void> stop() async {
    _log.info('Stopping UserWeightChangeIsolate...');
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await super.stop();
    _log.info('UserWeightChangeIsolate stopped.');
  }

  /* ---------- Connectivity management ---------- */

  void _onConnectivityChanged(ConnectivityResult result) {
    _log.fine('Connectivity changed: $result');
    if (result != ConnectivityResult.none) {
      _log.fine('Internet available, attempting sync...');
      _attemptSync();
    } else {
      _log.fine('No internet connection.');
    }
  }

  /* ---------- Supabase sync ---------- */

  String _keyForDate(DateTime date) =>
      DateTime(date.year, date.month, date.day).toString();

  Future<void> _attemptSync() async {
    if (_syncing) {
      _log.fine('Sync already in progress, skipping.');
      return;
    }
    _syncing = true;
    try {
      if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
        _log.fine('No connectivity, aborting sync.');
        return;
      }

      final dates = await getModifiedWeights();
      if (dates.isEmpty) {
        _log.fine('No modified weights to sync.');
        return;
      }

      _log.info('Starting sync for ${dates.length} weights.');
      for (var i = 0; i < dates.length; i += batchSize) {
        final batch = dates.skip(i).take(batchSize).toList();
        final entries = <Map<String, dynamic>>[];

        for (final date in batch) {
          final dbo = box.get(_keyForDate(date)) as UserWeightDbo?;
          if (dbo != null) entries.add(dbo.toJson());
        }

        if (entries.isNotEmpty) {
          if (await _connectivity.checkConnectivity() ==
              ConnectivityResult.none) {
            _log.warning('Lost connectivity during sync, will retry later.');
            break;
          }

          _log.info('Upserting ${entries.length} user weights to Supabase.');
          await _service.upsertUserWeights(entries);
          await removeItems(batch);
          _log.fine('Batch of ${batch.length} weights synced and removed.');
        }
      }
      _log.info('Sync completed.');
    } catch (e, stack) {
      _log.severe('Sync failed: $e', e, stack);
    } finally {
      _syncing = false;
    }
  }
}

