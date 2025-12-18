import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_service.dart';

class AzureService {
  static const String _url = String.fromEnvironment('API_BASE_URL');

  static Future<void> sendEvent(
    String type,
    SensorData data,
  ) async {

    await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'sensor': {
          'acc_x': data.ax,
          'acc_y': data.ay,
          'acc_z': data.az,
          'gyro_x': data.gx,
          'gyro_y': data.gy,
          'gyro_z': data.gz,
        },
      }),
    );
  }
}
