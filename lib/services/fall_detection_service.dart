import 'dart:math';
import 'dart:developer' as dev;
import 'tflite_service.dart';
import 'sensor_service.dart';

class FallConstants {
  // 중력 가속도 기준
  static const double gravity = 9.81;

  // 낙상 임계값
  static const double freeFallThreshold = 3.0;   // m/s²
  static const double impactThreshold = 20.0;    // m/s²

  // 시간 조건
  static const int impactWindowMs = 800;

  // 쿨다운 (연속 감지 방지)
  static const int cooldownSeconds = 10;

  // ML 앙상블 임계값
  static const double mlScoreThreshold = 0.3;
}

class FallDetectionService {
  final TFLiteService _tfliteService;

  DateTime? _lastImpact;
  DateTime? _lastFall;

  FallDetectionService(this._tfliteService);

  bool isFall(SensorData data) {
    final ax = data.ax;
    final ay = data.ay;
    final az = data.az;

    final magnitude = sqrt(ax * ax + ay * ay + az * az);

    final now = DateTime.now();

    // 쿨다운
    if (_lastFall != null &&
        now.difference(_lastFall!).inSeconds <
            FallConstants.cooldownSeconds) {
      dev.log('In cooldown period');
      return false;
    }

    // // 규칙 기반 자유낙하
    // if (magnitude < FallConstants.freeFallThreshold) {
    //   _lastImpact = now;
    //   dev.log('Free fall detected');
    //   return false;
    // }

    // // 규칙 기반 충격
    // if (_lastImpact != null &&
    //   magnitude > FallConstants.impactThreshold &&
    //   now.difference(_lastImpact!).inMilliseconds <
    //     FallConstants.impactWindowMs) {

    //   // ML 확증 단계
    //   final mlScore = _tfliteService.predict(data);

    //   if (mlScore > FallConstants.mlScoreThreshold) {
    //     _lastFall = now;
    //     dev.log('Fall detected with ML score: $mlScore');
    //     return true;
    //   }
    // }

    final mlScore = _tfliteService.predict(data);

    if (mlScore > FallConstants.mlScoreThreshold) {
      _lastFall = now;
      dev.log('Fall detected with ML score: $mlScore - $now');
      return true;
    }
    dev.log('No fall detected - $now');
    return false;
  }
}
