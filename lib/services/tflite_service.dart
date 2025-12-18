import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'sensor_service.dart';

class TFLiteService {
  late Interpreter _interpreter;
  bool _initialized = false;
 
  /// ===============================
  /// Configuration
  /// ===============================
  static const int WINDOW_SIZE = 100;
  static const double FALL_THRESHOLD = 0.5;
  
  /// ===============================
  /// Sliding Windows (axis-wise)
  /// ===============================
  final List<double> _accXWindow = [];
  final List<double> _accYWindow = [];
  final List<double> _accZWindow = [];
  
  final List<double> _gyroXWindow = [];
  final List<double> _gyroYWindow = [];
  final List<double> _gyroZWindow = [];

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/fall_detection_base_v5.tflite',
      options: InterpreterOptions()..threads = 2,
    );

    _interpreter!.allocateTensors();
    _initialized = true;
  }

  /// ===============================
  /// Sliding Window Update (FIFO)
  /// ===============================
  ///
  /// - Append new value
  /// - If window size exceeds WINDOW_SIZE,
  ///   remove the oldest value
  ///
  void _updateWindow(List<double> window, double value) {
    window.add(value);
    if (window.length > WINDOW_SIZE) {
      window.removeAt(0);
    }
  }

  /// ===============================
  /// Helper Functions
  /// ===============================
  double _mean(List<double> data) =>
      data.reduce((a, b) => a + b) / data.length;
  
  double _std(List<double> data) {
    final m = _mean(data);
    return sqrt(
      data.map((x) => pow(x - m, 2)).reduce((a, b) => a + b) / data.length
    );
  }
  
  double _max(List<double> data) =>
      data.reduce((a, b) => a > b ? a : b);

  double predict(SensorData sensor) {
    if (!_initialized || _interpreter == null) {
      throw Exception('Model not loaded');
    }

    final double accX = sensor.ax;
    final double accY = sensor.ay;
    final double accZ = sensor.az;
    final double gyroX = sensor.gx;
    final double gyroY = sensor.gy;
    final double gyroZ = sensor.gz;

    // 1️⃣ Update sliding windows (FIFO)
    _updateWindow(_accXWindow, accX);
    _updateWindow(_accYWindow, accY);
    _updateWindow(_accZWindow, accZ);
  
    _updateWindow(_gyroXWindow, gyroX);
    _updateWindow(_gyroYWindow, gyroY);
    _updateWindow(_gyroZWindow, gyroZ);
  
    // 2️⃣ Not enough data → skip inference
    if (_accXWindow.length < WINDOW_SIZE) {
      return 0;
    }

    // 3️⃣ Feature extraction (18 features)
    final features = <double>[
      // Accelerometer: mean
      _mean(_accXWindow),
      _mean(_accYWindow),
      _mean(_accZWindow),
  
      // Accelerometer: std
      _std(_accXWindow),
      _std(_accYWindow),
      _std(_accZWindow),
  
      // Accelerometer: max
      _max(_accXWindow),
      _max(_accYWindow),
      _max(_accZWindow),
  
      // Gyroscope: mean
      _mean(_gyroXWindow),
      _mean(_gyroYWindow),
      _mean(_gyroZWindow),
  
      // Gyroscope: std
      _std(_gyroXWindow),
      _std(_gyroYWindow),
      _std(_gyroZWindow),
  
      // Gyroscope: max
      _max(_gyroXWindow),
      _max(_gyroYWindow),
      _max(_gyroZWindow),
    ];

    // 4️⃣ TFLite inference (input shape: [1, 18])
    final input = [features];
    final output = [
      [0.0]
    ];
 
    _interpreter.run(input, output);
 
    return output[0][0];
  }

  void close() {
    _interpreter?.close();
  }
}
