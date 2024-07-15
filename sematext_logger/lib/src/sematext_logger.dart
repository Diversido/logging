import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:sematext_logger/src/logsene.dart';
import 'package:sematext_logger/src/logsene_client.dart';
import 'package:sematext_logger/src/utils/sematext_log_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SematextLogger extends EnrichableLogger {
  static const String cachedLogLevelKey = 'sematext_cached_log_level';

  late final Logsene _logsene;

  final LogLevel _defaultLogLevel = LogLevel.info;
  late final LogLevel _currentLogLevel;

  static late final SharedPreferences? _prefs;
  static Future<SharedPreferences> get _sharedPrefs async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    return _prefs!;
  }

  SematextLogger._({
    required String sematextKey,
    required LogLevel? logLevel,
    List<Enricher>? enrichers,
  }) {
    _currentLogLevel = logLevel ?? _defaultLogLevel;
    minLogLevel = _currentLogLevel;

    _logsene = Logsene(
      LogseneClient(sematextKey),
      const Duration(seconds: 10),
      Hive,
    );

    if (enrichers != null) {
      addEnrichers(enrichers);
    }

    Logsene.activateLogging(_logsene);
  }

  static Future<SematextLogger> initialize({
    required String sematextKey,
    List<Enricher>? enrichers,
  }) async {
    final cachedLogLevelString = (await _sharedPrefs).getString(cachedLogLevelKey);
    final cachedLogLevel = LogLevel.values.firstWhereOrNull(
      (l) => l.name == cachedLogLevelString,
    );

    return SematextLogger._(
      sematextKey: sematextKey,
      logLevel: cachedLogLevel,
      enrichers: enrichers,
    );
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

  @override
  void changeLogLevel(LogLevel newLogLevel) async {
    final previousLogLevel = _currentLogLevel;

    if (previousLogLevel != newLogLevel) {
      await (await _sharedPrefs).setString(cachedLogLevelKey, newLogLevel.name);

      _currentLogLevel = newLogLevel;
      minLogLevel = _currentLogLevel;

      Logger.logInfo(
        "Switching log level from: {PrevLogLevel}  to: {NewLoglevel}",
        args: [
          previousLogLevel,
          newLogLevel,
        ],
      );
    }
  }
}
