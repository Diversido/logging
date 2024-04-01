import 'dart:convert';

import 'log_record.dart';

class Bulk {
  final List<LogRecord> logs;

  Bulk(this.logs);

  String toBody(String token) {
    StringBuffer body = StringBuffer();
    for (var log in logs) {
      body.writeln(
        jsonEncode({
          "index": {"_index": token, "_type": log.type}
        }),
      );
      body.writeln(jsonEncode(log.data));
    }
    return body.toString();
  }
}
