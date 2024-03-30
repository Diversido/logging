enum LogLevel {
  debug,
  info,
  warning,
  error,
}

extension LogLevelExtensions on LogLevel {
  String get name => toString().split('.').last;

  bool equalOrGreater(LogLevel another) => index >= another.index;

  bool operator >=(LogLevel level) => index >= level.index;
}