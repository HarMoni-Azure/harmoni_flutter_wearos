import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/sensor_service.dart';
import 'services/tflite_service.dart';

class AppInitializer extends StatelessWidget {
  final Widget child;
  final SensorService sensor;
  final TFLiteService tflite;

  const AppInitializer({
    super.key,
    required this.child,
    required this.sensor,
    required this.tflite,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SensorService>.value(value: sensor),
        Provider<TFLiteService>.value(value: tflite),
      ],
      child: child,
    );
  }
}
