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
  Future<void> log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
    List<Object?>? args,
  ]) async {
    // Zone.root.print is used to avoid Stack Overflow exception that happens due to the fact
    // we wrap our app with Zone and redirect all the prints into our Logger
    // as soon as it's removed, we can replace `Zone.root.print` with a simple `print`
    Zone.root.print(
      formatMessage(
        level,
        message,
        args: args,
      ),
    );

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
  String formatMessage(
    LogLevel level,
    String message, {
    List<Object?>? args,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? enrichersData,
  }) {
    final logFormatter = LogFormatter();

    var formattedMassege = super.formatMessage(level, message);

    if (args != null) {
      formattedMassege = logFormatter.applyArgsToLogTemplate(
        formattedMassege,
        args,
      );
    }

    return formattedMassege;
  }
}
