import 'dart:async';
import 'package:flutter/foundation.dart';

import '../services/sensor_service.dart';
import '../services/tflite_service.dart';

enum AppPhase {
  monitoring,
  countdown,
  autoReported,
}

class FallController extends ChangeNotifier {
  final SensorService sensor;
  final TFLiteService tflite;

  StreamSubscription? _subscription;

  AppPhase phase = AppPhase.monitoring;
  bool processing = false;

  /// 마지막으로 감지를 무시해야 하는 시각
  DateTime? _cooldownUntil;

  /// Azure 전송용 마지막 센서 데이터
  SensorData? lastSensorData;

  /// 쿨다운 시간 (테스트용: 5초)
  static const Duration cooldownDuration = Duration(seconds: 5);

  FallController(this.sensor, this.tflite) {
    start();
  }

  void start() {
    sensor.start();

    _subscription ??= sensor.sensorStream.listen((data) {
      lastSensorData = data;

      final now = DateTime.now();

      // ⭐ 1. 쿨다운 중이면 감지 완전 무시
      if (_cooldownUntil != null &&
          now.isBefore(_cooldownUntil!)) {
        return;
      }

      // ⭐ 2. 이미 처리 중이면 무시
      if (processing) return;

      final score = tflite.predict(data);
      if (score >= 0.4) {
        processing = true;
        phase = AppPhase.countdown;
        notifyListeners();
      }
    });
  }

  void cancelCountdown() {
    processing = false;
    phase = AppPhase.monitoring;

    // ⭐ 지금 시점부터 쿨다운 시작
    _cooldownUntil = DateTime.now().add(cooldownDuration);

    notifyListeners();
  }

  /// 10초 무응답 → 자동 신고
  void autoReport() {
    phase = AppPhase.autoReported;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
