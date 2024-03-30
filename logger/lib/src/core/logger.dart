import 'package:logger/logger.dart';

abstract class Logger {
  static final _loggers = <Logger>[];
  static final _enrichers = <Enricher>[];

  static void addInstance(Logger logger) => _loggers.add(logger);
  static void removeInstance(Logger logger) => _loggers.remove(logger);

  static void addEnricher(Enricher enricher) => _enrichers.add(enricher);
  static void removeEnricher(Enricher enricher) => _enrichers.remove(enricher);

  static void logDebug(
    String message, {
    List<Object?> args = const [],
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: LogLevel.debug,
      message: message,
      args: args,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logInfo(
    String message, {
    List<Object?> args = const [],
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: LogLevel.info,
      message: message,
      args: args,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logWarning(
    String message, {
    List<Object?> args = const [],
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: LogLevel.warning,
      message: message,
      args: args,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static Future<void> logError(
    String message, {
    List<Object?> args = const [],
    Object? error,
    StackTrace? stackTrace,
  }) async {
    return _log(
      level: LogLevel.error,
      message: message,
      args: args,
      error: error,
      stackTrace: stackTrace,
    );
  }

  LogLevel minLogLevel = LogLevel.debug;

  Future<void> log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  ]);

  String formatMessage(
    LogLevel level,
    String message, {
    List<Object?>? args,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? enrichersData,
  }) =>
      '[${level.name}] $message';

  Future<Map<String, String>?> enrich() async {
    final List<Future<Map<String, String>>> enrichingTasks = [];

    for (var enricher in _enrichers) {
      enrichingTasks.add(enricher.enrich());
    }

    final results = await Future.wait<Map<String, String>>(enrichingTasks);

    final enrichersData = <String, String>{};

    for (var result in results) {
     enrichersData.addAll(result);
    }

    return enrichersData.isEmpty ? null : enrichersData;
  }

  static Future<void> _log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  }) async {
    final loggers = _loggers.where(
      (logger) => level.equalOrGreater(logger.minLogLevel),
    );

    final loggingFutures = loggers.map(
      (logger) => logger.log(
        level,
        message,
        error,
        stackTrace,
        args,
      ),
    );

    await Future.wait(loggingFutures);
  }
}
