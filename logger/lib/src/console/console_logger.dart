import 'dart:async';

import 'package:logger/src/core/log_level.dart';
import 'package:logger/src/core/logger_instance_interface.dart';
import 'package:logger/src/utils/log_formatter.dart';

class ConsoleLogger extends ILogger {
  final bool printException;

  /// Use 'printException = false' to prevent error and stackTrace print to console.
  /// This is useful when there is another Logger used, that traces this information,
  /// for example Crashlytics automatically prints these to console, and you might want to avoid duplicates.
  ConsoleLogger({this.printException = true});

  @override
  void log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  ]) async {
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
    final formattedMessage = await formatMessage(
      level,
      message,
      args: args,
    );
    // Zone.root.print is used to avoid Stack Overflow exception that happens due to the fact
    // we wrap our app with Zone and redirect all the prints into our Logger
    // as soon as it's removed, we can replace `Zone.root.print` with a simple `print`
    Zone.root.print(formattedMessage);

    if (printException) {
      if (error != null) {
        Zone.root.print(error.toString());
      }
      if (stackTrace != null) {
        Zone.root.print(stackTrace.toString());
      }
    }
  }

  @override
  Future<String> formatMessage(
    LogLevel level,
    String message, {
    List<Object?>? args,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? enrichersData,
  }) async {
    final logFormatter = LogFormatter();

    var formattedMessage = await super.formatMessage(level, message);

    if (args != null) {
      formattedMessage = logFormatter.applyArgsToLogTemplate(
        formattedMessage,
        args,
      );
    }

    return formattedMessage;
  }

  @override
  void changeLogLevel(LogLevel newLogLevel) {
    log(LogLevel.debug, "Changing log level to ${newLogLevel.name}");

    super.changeLogLevel(newLogLevel);
  }
}
