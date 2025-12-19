import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/fall_controller.dart';
import 'services/sensor_service.dart';
import 'services/tflite_service.dart';
import 'services/device_service.dart';
import 'screens/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DeviceService().init(); // ⭐ 최초 1회

  final sensor = SensorService();
  final tflite = TFLiteService();
  
  try{
    await tflite.init();
    print('TFLite init success');
  } catch(e, s){
    print('TFLite init failed: $e');
    print(s);
  }

  runApp(MyApp(sensor: sensor, tflite: tflite));
}

class MyApp extends StatelessWidget {
  final SensorService sensor;
  final TFLiteService tflite;

  const MyApp({
    super.key,
    required this.sensor,
    required this.tflite,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FallController(sensor, tflite),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RootPage(),
      ),
    );
  }
}
