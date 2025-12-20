package com.example.harmoni_flutter_wearos

import android.content.Context
import android.content.pm.PackageManager
import android.Manifest
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.activity.ComponentActivity
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val CHANNEL = "harmoni/vibration"
    private val HEART_RATE_CHANNEL = "harmoni/heart_rate_stream"

    private var heartRateManager: HealthServiceManager? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HEART_RATE_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events

                heartRateManager = HealthServiceManager(this@MainActivity) { bpm ->
                    eventSink?.success(bpm)
                }

                heartRateManager?.start()
            }

            override fun onCancel(arguments: Any?) {
                heartRateManager?.stop()
                heartRateManager = null
                eventSink = null
            }
        })

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
