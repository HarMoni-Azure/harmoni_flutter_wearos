package com.example.harmoni_flutter_wearos

import android.os.VibrationEffect
import android.os.Vibrator
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "harmoni/vibration"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "vibrate") {
                    val vibrator =
                        getSystemService(Context.VIBRATOR_SERVICE) as Vibrator

                    vibrator.vibrate(
                        VibrationEffect.createOneShot(
                            300,
                            VibrationEffect.DEFAULT_AMPLITUDE
                        )
                    )
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
