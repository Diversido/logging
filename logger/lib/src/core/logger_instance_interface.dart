import 'package:dixo_logger/logger.dart';

abstract class ILogger {
  LogLevel minLogLevel = LogLevel.debug;

  void log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  ]);

  Future<String> formatMessage(
    LogLevel level,
    String message, {
    List<Object?>? args,
    Object? error,
    StackTrace? stackTrace,
  }) async =>
      '[${level.name}] $message';

  void changeLogLevel(LogLevel newLogLevel) => minLogLevel = newLogLevel;
}
