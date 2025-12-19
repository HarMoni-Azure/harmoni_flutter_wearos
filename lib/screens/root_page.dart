import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/fall_controller.dart';
import '../controllers/countdown_controller.dart';
import '../screens/countdown_screen.dart';
import '../screens/monitoring_screen.dart';
import '../screens/auto_reported_screen.dart';
import '../services/azure_service.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

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
