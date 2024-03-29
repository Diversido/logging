import 'package:logger/src/log_level.dart';

abstract class Logger {
  static final _loggers = <Logger>[];

  static void addInstance(Logger logger) => _loggers.add(logger);
  
  static void removeInstance(Logger logger) => _loggers.remove(logger);

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
  }) =>
      '[${level.name}] $message';

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