import 'dart:async';
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Internal command: remove a set of items from the `modified` set.
class _RemoveCommand {
  final List<dynamic> items;
  final SendPort? responsePort;
  const _RemoveCommand(this.items, {this.responsePort});
}

/// Generic isolate that collects objects of type [T] emitted by a Hive box.
class ChangeIsolate<T> {
  final Box box;
  final T? Function(BoxEvent event) extractor;

  void Function()? onItemCollected;

  Isolate? _isolate;
  SendPort? _sendPort;
  StreamSubscription<BoxEvent>? _subscription;

  final Logger _log = Logger('ChangeIsolate');

  ChangeIsolate({
    required this.box,
    required this.extractor,
    this.onItemCollected,
  });

  /* ---------- Lifecycle ---------- */

  Future<void> start() async {
    if (_isolate != null) {
      _log.fine('Isolate already started.');
      return;
    }

    // 1) Start the collector isolate
    final readyPort = ReceivePort();
    _isolate = await Isolate.spawn(_entryPoint, readyPort.sendPort);
    _sendPort = await readyPort.first as SendPort;
    _log.info('Collector isolate started.');

    // 2) Listen to changes in the Hive box
    _subscription = box.watch().listen((event) {
      final msg = extractor(event);
      if (msg != null) {
        _log.fine('Box event collected: $msg');
        _sendPort?.send(msg); // send to secondary isolate
        onItemCollected?.call(); // optional trigger
      }
    });
    _log.fine('Box watcher subscription started.');
  }

  Future<void> stop() async {
    _log.info('Stopping ChangeIsolate...');
    await _subscription?.cancel();
    _isolate?.kill(priority: Isolate.immediate);
    _subscription = null;
    _isolate = null;
    _sendPort = null;
    _log.info('ChangeIsolate stopped.');
  }

  /* ---------- Public API ---------- */

  Future<List<T>> getItems() async {
    if (_sendPort == null) {
      _log.warning(
          'getItems called but sendPort is null. Returning empty list.');
      return <T>[];
    }
    final response = ReceivePort();
    _sendPort!.send(response.sendPort);
    final result = await response.first;
    _log.fine('getItems returned ${result is List ? result.length : 0} items.');
    return (result as List).cast<T>();
  }

  Future<void> removeItems(List<T> items) async {
    if (_sendPort == null || items.isEmpty) {
      _log.fine('removeItems called with empty items or null sendPort.');
      return;
    }
    _log.fine('Removing ${items.length} items from modified set.');
    final ack = ReceivePort();
    _sendPort!.send(_RemoveCommand(items, responsePort: ack.sendPort));
    await ack.first; // wait for confirmation
  }

  /* ---------- Secondary isolate ---------- */

  static void _entryPoint(SendPort initSendPort) {
    final port = ReceivePort();
    final modified = <dynamic>{};
    initSendPort.send(port.sendPort); // send SendPort to parent

    port.listen((message) {
      if (message is SendPort) {
        message.send(modified.toList()); // getItems()
      } else if (message is _RemoveCommand) {
        modified.removeAll(message.items); // removeItems()
        message.responsePort?.send(null); // acknowledge completion
      } else {
        modified.add(message); // add new item
      }
    });
  }
}
