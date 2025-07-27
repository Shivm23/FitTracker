import 'dart:io';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:opennutritracker/core/utils/hive_db_provider.dart';
import 'package:opennutritracker/core/data/data_source/user_weight_dbo.dart';
import 'package:opennutritracker/core/data/repository/user_weight_repository.dart';
import 'package:opennutritracker/core/data/data_source/user_weight_data_source.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_entity.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/features/sync/user_weight_change_isolate.dart';
import 'package:opennutritracker/features/sync/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

class FakeConnectivity extends Mock implements Connectivity {
  final _controller = StreamController<ConnectivityResult>.broadcast();
  ConnectivityResult _result = ConnectivityResult.none;

  @override
  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;

  @override
  Future<ConnectivityResult> checkConnectivity() async => _result;

  void emit(ConnectivityResult result) {
    _result = result;
    _controller.add(result);
  }

  Future<void> close() async {
    await _controller.close();
  }
}

Future<void> waitForCondition(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (await condition()) return;
    await Future.delayed(const Duration(milliseconds: 10));
  }
  throw TimeoutException('Condition not met within $timeout');
}

void main() {
  group('UserWeightChangeIsolate', () {
    late Directory tempDir;
    late Box<UserWeightDbo> box;
    late UserWeightChangeIsolate watcher;
    late FakeConnectivity connectivity;
    late SupabaseClient mockSupabase;
    late MockSupabaseHttpClient mockHttpClient;
    late SupabaseUserWeightService weightService;
    late UserWeightRepository repo;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      tempDir = await Directory.systemTemp.createTemp('hive_test_isolate_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(18)) {
        Hive.registerAdapter(UserWeightDboAdapter());
      }
      box = await Hive.openBox<UserWeightDbo>('user_weight_test');
      final hive = HiveDBProvider();
      hive.userWeightBox = box;

      repo = UserWeightRepository(UserWeightDataSource(hive));

      mockHttpClient = MockSupabaseHttpClient();
      mockSupabase = SupabaseClient(
        'https://mock.supabase.co',
        'fakeAnonKey',
        httpClient: mockHttpClient,
      );
      weightService = SupabaseUserWeightService(client: mockSupabase);

      connectivity = FakeConnectivity();

      watcher = UserWeightChangeIsolate(
        box,
        service: weightService,
        connectivity: connectivity,
      );
      await watcher.start();
    });

    tearDown(() async {
      await watcher.stop();
      await connectivity.close();
      await box.close();
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test('captures modified weight when box updates', () async {
      final date = DateTime.utc(2024, 1, 1);
      final entity = UserWeightEntity(
        id: IdGenerator.getUniqueID(),
        weight: 80,
        date: date,
      );
      await repo.addUserWeight(entity);

      await waitForCondition(
          () async => (await watcher.getModifiedWeights()).contains(date));

      final modified = await watcher.getModifiedWeights();
      expect(modified, contains(date));
    });

    test('syncs modified weights when connectivity is restored', () async {
      final date = DateTime.utc(2024, 1, 2);
      await repo.addUserWeight(
        UserWeightEntity(
          id: IdGenerator.getUniqueID(),
          weight: 81,
          date: date,
        ),
      );

      await waitForCondition(
          () async => (await watcher.getModifiedWeights()).contains(date));

      connectivity.emit(ConnectivityResult.wifi);

      await waitForCondition(
          () async => (await watcher.getModifiedWeights()).isEmpty);

      final result = await mockSupabase.from('user_weight').select();
      expect(result.length, 1);
      expect(DateTime.parse(result.first['date']), date);
    });
  });
}
