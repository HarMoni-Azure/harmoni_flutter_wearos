import 'package:flutter/services.dart';

class VibrationService {
  static const MethodChannel _channel =
      MethodChannel('harmoni/vibration');

  static Future<void> vibrateOnce() async {
    try {
      await _channel.invokeMethod('vibrate');
    } catch (_) {}
  }
}
