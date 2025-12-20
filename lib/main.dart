import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_initializer.dart';
import 'controllers/fall_controller.dart';
import 'services/sensor_service.dart';
import 'services/tflite_service.dart';
import 'services/device_service.dart';
import 'screens/root_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DeviceService().init(); // ⭐ 최초 1회

  // ✅ ML 모델 초기화 (1회)
  final tflite = TFLiteService();
  await tflite.init();

  final sensor = SensorService();

  runApp(
    AppInitializer(
      sensor: sensor,
      tflite: tflite,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FallController>(
      create: (_) => FallController(
        context.read<SensorService>(),
        context.read<TFLiteService>(),
      ),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RootPage(),
      ),
    );
  }
}
