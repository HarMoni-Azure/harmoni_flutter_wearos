import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_service.dart';
import 'device_service.dart';

class AzureService {
  static const String _url = String.fromEnvironment('API_BASE_URL');

  static Future<void> sendEvent(
    String type,
    List<double> data,
  ) async {
    final device = DeviceService();

    await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'sensor': data,
        'device': device.toJson(),
      }),
    );
  }
}
