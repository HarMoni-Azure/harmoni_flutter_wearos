import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_service.dart';

class ReportService {
  static const String _url = String.fromEnvironment('WEBHOOK_URL');
  static const String _sig = String.fromEnvironment('WEBHOOK_SIG');
  static const String _url2 = String.fromEnvironment('SIGNALR_URL');

  static Future<void> sendWebhookEvent(
    String type
  ) async {
    try {
      final device = DeviceService();

      final uri = Uri.parse(_url).replace(
        queryParameters: {
          'api-version': '1',
          'sp': '/triggers/manual/run',
          'sv': '1.0',
          'sig': _sig,
        },
      );

      final reqBody = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'device': device.toJson(),
      };

      print('data for webhook : ${reqBody}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reqBody),
      );

      // 4️⃣ 응답 로그
      print('✅ [WEBHOOK] RESPONSE');
      print('statusCode = ${response.statusCode}');
      print('body = ${response.body}');

      // 5️⃣ 성공 판정
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('🎉 [WEBHOOK] POST SUCCESS');
      } else {
        print('❌ [WEBHOOK] POST FAILED (Server responded)');
      }
    } catch (e, s) {
      // 6️⃣ 네트워크 / 파싱 / 타임아웃 예외
      print('🔥 [WEBHOOK] EXCEPTION');
      print(e);
      print(s);
    }
  }

  static Future<void> sendSignalREvent(
    String type
  ) async {
    try {
      final device = DeviceService();

      final uri = Uri.parse(_url2);

      final reqBody = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'device': device.toJson(),
      };

      print('data for signalR : ${reqBody}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reqBody),
      );

      // 4️⃣ 응답 로그
      print('✅ [SIGNALR] RESPONSE');
      print('statusCode = ${response.statusCode}');
      print('body = ${response.body}');

      // 5️⃣ 성공 판정
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('🎉 [SIGNALR] POST SUCCESS');
      } else {
        print('❌ [SIGNALR] POST FAILED (Server responded)');
      }
    } catch (e, s) {
      // 6️⃣ 네트워크 / 파싱 / 타임아웃 예외
      print('🔥 [SIGNALR] EXCEPTION');
      print(e);
      print(s);
    }
  }

}

