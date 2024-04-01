import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:sematext_logger/src/logsene.dart';
import 'package:sematext_logger/src/logsene_client.dart';
import 'package:sematext_logger/src/utils/sematext_log_formatter.dart';

class SematextLogger extends EnrichableLogger {
  late final Logsene _logsene;

  SematextLogger({
    required String sematextKey,
    LogLevel? minLogLevel,
    List<Enricher>? enrichers,
  }) {
    _logsene = Logsene(
      LogseneClient(sematextKey),
      const Duration(seconds: 10),
      Hive,
    );

    if (minLogLevel != null) {
      this.minLogLevel = minLogLevel;
    }

    if (enrichers != null) {
      addEnrichers(enrichers);
    }

    Logsene.activateLogging(_logsene);
  }

  @override
  Future<String> formatMessage(
    LogLevel level,
    String message, {
    List<Object?>? args,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final logFormatter = SematextLogFormatter();

    final formattedLog = {
      "@timestamp": DateTime.now().toUtc().toIso8601String(),
      "MessageTemplate": message,
      "Message": logFormatter.applyArgsToLogTemplate(message, args),
      "LogLevel": level.name,
    };

    if (error != null) {
      formattedLog["Exception"] = error.toString();
    }

    if (stackTrace != null) {
      formattedLog["StackTrace"] = stackTrace.toString();
    }

    final messageTemplateProperties =
        logFormatter.convertToKeyValuePairs(message, args);

    if (messageTemplateProperties.isNotEmpty) {
      formattedLog.addAll(messageTemplateProperties);
    }

    // Enriching with enrichers data
    final enrichersData = await getEnrichersData();
    if (enrichersData?.isNotEmpty == true) {
      formattedLog.addAll(enrichersData!);
    }

    return jsonEncode(formattedLog);
  }

  @override
  void log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  ]) {
    _logAsync(
      level,
      message,
      error,
      stackTrace,
      args,
    );
  }

  Future<void> _logAsync(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  ]) async {
    final formattedLog = await formatMessage(
      level,
      message,
      args: args,
      error: error,
      stackTrace: stackTrace,
    );

    final logData = (jsonDecode(formattedLog) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    _logsene.log(logData);
  }
}
