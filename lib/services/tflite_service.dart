import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter _interpreter;
  bool _initialized = false;
 
  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/latest_model_v4.tflite',
      options: InterpreterOptions()
        ..threads = 1
        ..useNnApiForAndroid = false,
    );
    _initialized = true;
  }

  double predict(List<double> input) {
    if (!_initialized) {
      throw Exception('Model not loaded');
    }

    // TFLite inference (input shape: [1, windowSize*6])
    assert(input.length == 768);

    final inputTensor = Float32List.fromList(input);
    final inputShaped = [inputTensor]; // Shape: [1, 768]

    final output = List.generate(1, (_) => List.filled(1, 0.0)); // Shape: [1, 1]

    _interpreter.run(inputShaped, output);
 
    return output[0][0];
  }

  void close() {
    _interpreter.close();
  }
}
