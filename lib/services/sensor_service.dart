import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorData {
  final double ax, ay, az;
  final double gx, gy, gz;
  final int timestamp;

  SensorData({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.timestamp,
  });
}

class SensorService {
  AccelerometerEvent? _lastAccel;
  GyroscopeEvent? _lastGyro;

  final _controller = StreamController<SensorData>.broadcast();

  Stream<SensorData> get sensorStream => _controller.stream;

  void start() {
    accelerometerEvents.listen((event) {
      _lastAccel = event;
      _emit();
    });

    gyroscopeEvents.listen((event) {
      _lastGyro = event;
      _emit();
    });
  }

  void _emit() {
    _controller.add(SensorData(
        ax: _lastAccel?.x ?? 0,
        ay: _lastAccel?.y ?? 0,
        az: _lastAccel?.z ?? 0,
        gx: _lastGyro?.x ?? 0,
        gy: _lastGyro?.y ?? 0,
        gz: _lastGyro?.z ?? 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
  }

}
