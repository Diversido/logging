import 'package:hive/hive.dart';

part 'log_record.g.dart';

@HiveType(typeId: 223)
class LogRecord {
  @HiveField(0)
  final String type;
  @HiveField(1)
  final String timestamp;
  @HiveField(2)
  final Map<String, String> data;

  LogRecord({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}
