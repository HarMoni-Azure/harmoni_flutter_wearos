import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../services/sensor_service.dart';
import '../services/tflite_service.dart';
import '../services/azure_service.dart';

enum AppPhase {
  monitoring,
  countdown,
  autoReported,
}

class FallController extends ChangeNotifier {

  /// ===============================
  /// Configuration
  /// ===============================
  static const double FALL_THRESHOLD = 0.3;
  static const int windowSize = 64; // 1초 @ 64Hz

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

  final Queue<SensorData> _buffer = Queue();

  List<double>? _lastInferenceWindow;

  FallController(this.sensor, this.tflite) {
    start();
  }

  void start() {
    sensor.start();

    _subscription ??= sensor.sensorStream.listen((data) {
    
      final now = DateTime.now();

      // ⭐ 1. 쿨다운 중이면 감지 완전 무시
      if (_cooldownUntil != null &&
          now.isBefore(_cooldownUntil!)) {
        return;
      }

      // ⭐ 2. 이미 처리 중이면 무시
      if (processing) return;

      _buffer.addLast(data);
      if (_buffer.length < windowSize) return;

      if (_buffer.length > windowSize) {
        _buffer.removeFirst();
      }

      final input = <double>[];
      for (final s in _buffer) {
        input.addAll(s.toInputVector()); // ax ay az gx gy gz
      }

      // length == 384 보장
      final score = tflite.predict(input);
      
      if (score >= FALL_THRESHOLD) {
        // 🔑 스냅샷 저장
        _lastInferenceWindow = List<double>.from(input);
        processing = true;
        _sendSensorData("fall_detected");
        phase = AppPhase.countdown;
        notifyListeners();
      }
    });
  }

  void _sendSensorData(String type) {
    if (_lastInferenceWindow == null) return;

    AzureService.sendEvent(type, _lastInferenceWindow!);
  }

  void cancelCountdown() {
    processing = false;
    _buffer.clear();
    _lastInferenceWindow = null;
    phase = AppPhase.monitoring;

    // ⭐ 지금 시점부터 쿨다운 시작
    _cooldownUntil = DateTime.now().add(cooldownDuration);

    _sendSensorData("user_cancelled");

    notifyListeners();
  }

  /// 10초 무응답 → 자동 신고
  void autoReport() {
    phase = AppPhase.autoReported;

    _sendSensorData("auto_reported");

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
