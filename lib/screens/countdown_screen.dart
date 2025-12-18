import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/countdown_controller.dart';

class CountdownScreen extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onTimeout;

  const CountdownScreen({
    super.key,
    required this.onCancel,
    required this.onTimeout,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CountdownController>();

    if (controller.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onTimeout();
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🚨낙상 감지🚨',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              '${controller.remainingSeconds}',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.cancel();
                onCancel();
              },
              child: const Text('신고 취소'),
            ),
          ],
        ),
      ),
    );
  }
}
