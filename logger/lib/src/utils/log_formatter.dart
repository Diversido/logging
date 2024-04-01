class LogFormatter {
  static final argExp = RegExp(r'{[^{}]*}');

  /// Formats by sequentially substituting values from the arguments into the log template.
  String applyArgsToLogTemplate(String template, List<Object?>? args) {
    String templateWithPlaceholders = template;

    if (args != null && args.isNotEmpty) {
      int i = 0;

      templateWithPlaceholders = templateWithPlaceholders.replaceAllMapped(
        argExp,
        (match) {
          final newValue = '${args[i]}';
          i++;
          return newValue;
        },
      );
    }

    return templateWithPlaceholders;
  }
}
