package com.example.harmoni_flutter_wearos

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager

class HealthServiceManager(
    context: Context,
    private val onHeartRate: (Double) -> Unit
) : SensorEventListener {

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

    private val heartRateSensor: Sensor? =
        sensorManager.getDefaultSensor(Sensor.TYPE_HEART_RATE)

    fun start() {
        heartRateSensor?.let {
            sensorManager.registerListener(
                this,
                it,
                SensorManager.SENSOR_DELAY_NORMAL
            )
        }
    }

    fun stop() {
        sensorManager.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type == Sensor.TYPE_HEART_RATE) {
            val bpm = event.values.firstOrNull()?.toDouble()
            if (bpm != null && bpm > 0) {
                onHeartRate(bpm)
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}