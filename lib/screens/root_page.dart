import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/fall_controller.dart';
import '../controllers/countdown_controller.dart';
import '../screens/countdown_screen.dart';
import '../screens/monitoring_screen.dart';
import '../screens/auto_reported_screen.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();

    // ✅ UI 트리 완성 후 센서 + 추론 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FallController>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FallController>();

    switch (controller.phase) {
      case AppPhase.monitoring:
        return const MonitoringScreen();

      case AppPhase.countdown:
        return ChangeNotifierProvider(
          create: (_) {
            final c = CountdownController(durationSeconds: 10);
            c.start();
            return c;
          },
          child: CountdownScreen(
            onCancel: () async {
              controller.cancelCountdown();
            },
            onTimeout: () async {
              controller.autoReport();
            },
          ),
        );

      case AppPhase.autoReported:
        return const AutoReportedScreen();
    }
  }
}
