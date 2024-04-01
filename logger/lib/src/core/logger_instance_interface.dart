import 'package:logger/logger.dart';

abstract class ILogger {
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
}
