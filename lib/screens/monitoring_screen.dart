import 'package:flutter/material.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '낙상 감지 중...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
