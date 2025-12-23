import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../services/sensor_service.dart';
import '../services/tflite_service.dart';
import '../services/azure_service.dart';
import '../services/report_service.dart';

enum AppPhase {
  monitoring,
  countdown,
  autoReported,
}

class FallController extends ChangeNotifier {

  /// ===============================
  /// Configuration
  /// ===============================
  static const double FALL_THRESHOLD = 0.7;
  static const int windowSize = 128; // 1초 @ 128Hz

  final SensorService sensor;
  final TFLiteService tflite;

  StreamSubscription? _subscription;

  AppPhase phase = AppPhase.monitoring;
  bool _started = false;
  bool processing = false;

  /// 마지막으로 감지를 무시해야 하는 시각
  DateTime? _cooldownUntil;

  /// Azure 전송용 마지막 센서 데이터
  SensorData? lastSensorData;

  /// 쿨다운 시간 (테스트용: 5초)
  static const Duration cooldownDuration = Duration(seconds: 5);

  final Queue<SensorData> _buffer = Queue();

  List<Map<String, dynamic>> _lastInferenceWindow = [];

  FallController(this.sensor, this.tflite);

  /// ===============================
  /// Start sensing & inference
  /// ===============================
  void start() {
    if (_started) return;
    _started = true;
    
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
        input.addAll(s.toInputVector()); // ax ay az gx gy gz svm
        // 🔑 스냅샷 저장
        _lastInferenceWindow.add(s.toJson());
      }

      // length == windowSize * 6 보장
      final score = tflite.predict(input);
      
      if (score >= FALL_THRESHOLD) {
        processing = true;
        phase = AppPhase.countdown;
        notifyListeners();
      }
    });
  }

  Future<void> _sendSensorData(String type) async {
    if (_lastInferenceWindow.isEmpty) return;

    final res = await AzureService.sendEvent(type, _lastInferenceWindow);

    try{
      if (type == "auto_reported" && res.statusCode == 201) {
        ReportService.sendWebhookEvent(type);
        ReportService.sendSignalREvent(type);
      }
    } catch (e) {
      print('AzureService.sendEvent error: $e');
    } finally {
      // 전송 후 버퍼 및 스냅샷 초기화
      _lastInferenceWindow = [];
      _buffer.clear();
    }
  }

  void cancelCountdown() {
    processing = false;
    _buffer.clear();
    _lastInferenceWindow = [];
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

  /// 자동 신고 → 감지 화면
  void reset() {
    processing = false;
    phase = AppPhase.monitoring;
    
    _buffer.clear();
    _lastInferenceWindow = [];

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
