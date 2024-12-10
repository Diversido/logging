import 'package:dixo_logger/logger.dart';

abstract class Logger {
  static final _loggers = <ILogger>[];

  static void addInstance(ILogger logger) => _loggers.add(logger);
  static void removeInstance(ILogger logger) => _loggers.remove(logger);

  static void addEnrichers(List<Enricher> enrichers) {
    _loggers.whereType<EnrichableLogger>().map(
          (eLogger) => eLogger.addEnrichers(enrichers),
        );
  }

  static void removeEnrichers(List<Enricher> enrichers) {
    _loggers.whereType<EnrichableLogger>().map(
          (eLogger) => eLogger.removeEnrichers(enrichers),
        );
  }

  static void changeLogLevel(LogLevel newLogLevel) {
    _loggers.map((logger) => logger.changeLogLevel(newLogLevel));
  }

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

  static void logError(
    String message, {
    List<Object?> args = const [],
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: LogLevel.error,
      message: message,
      args: args,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  }) {
    final loggers = _loggers.where(
      (logger) => level.equalOrGreater(logger.minLogLevel),
    );

    loggers.map(
      (logger) => logger.log(
        level,
        message,
        error,
        stackTrace,
        args,
      ),
    );
  }
}
