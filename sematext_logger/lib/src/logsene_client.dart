import 'package:http/http.dart' as http;
import 'package:sematext_logger/src/bulk.dart';

class LogseneClient {
  final String _appToken;

  LogseneClient(
    this._appToken,
  );

  Future<bool> send(Bulk bulk) async {
    try {
      final url = Uri.https('https://logsene-receiver.sematext.com/_bulk');
      final response = await http.post(
        url,
        body: bulk.toBody(_appToken),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
