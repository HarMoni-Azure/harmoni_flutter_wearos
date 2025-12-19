import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorData {
  final double ax, ay, az;
  final double gx, gy, gz;

  SensorData({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
  });

  List<double> toInputVector() => [ax, ay, az, gx, gy, gz];
}

class SensorService {
  /// ===============================
  /// Configuration
  /// ===============================
  static const int hz = 64; // 64Hz
  static const Duration interval = Duration(milliseconds: 1000 ~/ hz);

  AccelerometerEvent? _lastAccel;
  GyroscopeEvent? _lastGyro;

  final _controller = StreamController<SensorData>.broadcast();

  Stream<SensorData> get sensorStream => _controller.stream;

  Timer? _timer;

  void start() {
    accelerometerEvents.listen((e) => _lastAccel = e);
    gyroscopeEvents.listen((e) => _lastGyro = e);

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
          )
        );
      }
    });

  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

}
