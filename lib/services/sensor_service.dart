import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorData {
  final double ax, ay, az;
  final double gx, gy, gz;
  final double? heartRate;

  SensorData({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    this.heartRate,
  });

  List<double> toInputVector() => [ax, ay, az, gx, gy, gz];

  Map<String, dynamic> toJson() => {
    'ax': ax,
    'ay': ay,
    'az': az,
    'gx': gx,
    'gy': gy,
    'gz': gz,
    'heartRate': heartRate,
  };
}

class SensorService {
  /// ===============================
  /// Configuration
  /// ===============================
  static const int hz = 128; // 128Hz
  static const Duration interval = Duration(milliseconds: 1000 ~/ hz);

  AccelerometerEvent? _lastAccel;
  GyroscopeEvent? _lastGyro;

  final _controller = StreamController<SensorData>.broadcast();

  Stream<SensorData> get sensorStream => _controller.stream;

  Timer? _timer;

  static const _hrChannel = EventChannel('harmoni/heart_rate_stream');
  double? _latestHeartRate;
  StreamSubscription? _hrSubscription;

  void start() {
    accelerometerEvents.listen((e) => _lastAccel = e);
    gyroscopeEvents.listen((e) => _lastGyro = e);
    _hrSubscription = _hrChannel.receiveBroadcastStream().listen(
      (hr) {
        _latestHeartRate = (hr as num).toDouble();
      },
    );

    _timer = Timer.periodic(interval, (_) {
      if (_lastAccel != null && _lastGyro != null) {
        _controller.add(
          SensorData(
            ax: _lastAccel?.x ?? 0,
            ay: _lastAccel?.y ?? 0,
            az: _lastAccel?.z ?? 0,
            gx: _lastGyro?.x ?? 0,
            gy: _lastGyro?.y ?? 0,
            gz: _lastGyro?.z ?? 0,
            heartRate: _latestHeartRate,
          )
        );
      }
    });

  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _hrSubscription?.cancel();
    _controller.close();
  }

}
