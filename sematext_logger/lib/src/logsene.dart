import 'dart:async';

import 'package:hive/hive.dart';
import 'package:dixo_sematext_logger/src/bulk.dart';
import 'package:dixo_sematext_logger/src/log_record.dart';
import 'package:dixo_sematext_logger/src/logsene_client.dart';

class Logsene {
  static const _boxName = 'logs';

  final Duration timeBetweenDispatches;
  final LogseneClient client;
  final HiveInterface hive;

  Logsene(
    this.client,
    this.timeBetweenDispatches,
    this.hive,
  );

  static void activateLogging(Logsene logsene) {
    final adapter = LogRecordAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
    _startLogging(logsene);
  }

  static void _startLogging(Logsene logsene) {
    Timer.periodic(
      logsene.timeBetweenDispatches,
      (timer) async {
        final box = await logsene.hive.openBox<LogRecord>(_boxName);
        final logs = box.values.toList();

        if (logs.isNotEmpty) {
          final isSuccess = await logsene.client.send(Bulk(logs));
          if (isSuccess) {
            await box.clear();
          }
        }
      },
    );
  }

  Future<void> log(
    Map<String, String> logData,
  ) {
    return _addToQueue(
      LogRecord(
        type: 'app',
        timestamp: DateTime.now().toIso8601String(),
        data: logData,
      ),
    );
  }

  Future<void> _addToQueue(LogRecord log) async {
    final box = await hive.openBox<LogRecord>(_boxName);
    await box.put(log.timestamp, log);
  }
}
