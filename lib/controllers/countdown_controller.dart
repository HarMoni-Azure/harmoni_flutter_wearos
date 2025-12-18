import 'dart:async';
import 'package:flutter/foundation.dart';

class CountdownController extends ChangeNotifier {
  final int durationSeconds;

  DateTime? _endTime;
  Timer? _ticker;

  int remainingSeconds = 0;
  bool isFinished = false;

  CountdownController({this.durationSeconds = 10});

  void start() {
    _endTime ??= DateTime.now().add(
      Duration(seconds: durationSeconds),
    );

    _tick();

    _ticker ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _tick() {
    final diff = _endTime!.difference(DateTime.now()).inSeconds;

    remainingSeconds = diff > 0 ? diff : 0;

    if (remainingSeconds == 0 && !isFinished) {
      isFinished = true;
      _ticker?.cancel();
    }

    notifyListeners();
  }

  void cancel() {
    _ticker?.cancel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
