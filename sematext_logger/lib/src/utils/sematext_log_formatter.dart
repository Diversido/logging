import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

class SematextLogFormatter extends LogFormatter {
  /// If 'formatted' is true, then result list contains [name1, name2, ...]
  /// otherwise the list contains [{name1}, {name2}, ...]
  List<String>? getArgsNames(
    String template, {
    bool formatted = true,
  }) {
    final matches = LogFormatter.argExp
        .allMatches(template)
        .map((match) => match.group(0))
        .toList();

    final hasValidMatch = matches.firstWhereOrNull(
          (element) => element != null && element.isNotEmpty,
        ) !=
        null;

    final hasMatches = matches.isNotEmpty && hasValidMatch;

    List<String>? argsNames;

    if (hasMatches) {
      final List<String> unformattedArgsNames = [];

      for (var match in matches) {
        if (match != null && match.isNotEmpty) {
          unformattedArgsNames.add(match);
        }
      }

      if (formatted) {
        final List<String> formattedArgsNames = unformattedArgsNames
            .map((name) => name.substring(1, name.length - 1))
            .toList();

        argsNames = formattedArgsNames;
      } else {
        argsNames = unformattedArgsNames;
      }
    }

    return argsNames;
  }

  Map<String, String> convertToKeyValuePairs(
    String template,
    List<Object?>? args,
  ) {
    final keyValuePairs = <String, String>{};

    final argsNames = getArgsNames(template);

    final hasKeysAndValues = argsNames != null &&
        argsNames.isNotEmpty &&
        args != null &&
        args.isNotEmpty;

    if (hasKeysAndValues) {
      for (int i = 0; i < argsNames.length; i++) {
        final key = argsNames[i];

        // if args list does not have enough values - use empty string
        // so logs let us know about this
        final value = i <= args.length - 1 ? args[i].toString() : '';

        keyValuePairs[key] = value;
      }
    }

    return keyValuePairs;
  }
}
