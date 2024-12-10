import 'package:dixo_logger/logger.dart';

abstract class EnrichableLogger extends ILogger {
  final _enrichers = <Enricher>[];

  void addEnrichers(List<Enricher> enrichers) => _enrichers.addAll(enrichers);

  void removeEnrichers(List<Enricher> enrichers) => _enrichers.removeWhere(
        (e) => enrichers.contains(e),
      );

  Future<Map<String, String>?> getEnrichersData() async {
    final List<Future<Map<String, String>>> enrichingTasks = [];

    for (var enricher in _enrichers) {
      enrichingTasks.add(enricher.enrich());
    }
    final results = await Future.wait(enrichingTasks);

    final enrichersData = <String, String>{};

    for (var result in results) {
      enrichersData.addAll(result);
    }

    return enrichersData.isEmpty ? null : enrichersData;
  }
}
