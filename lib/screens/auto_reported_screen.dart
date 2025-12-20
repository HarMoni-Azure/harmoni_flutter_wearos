import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/fall_controller.dart';

class AutoReportedScreen extends StatelessWidget {
  const AutoReportedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<FallController>();
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📱자동신고 완료',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.reset();
              },
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}
