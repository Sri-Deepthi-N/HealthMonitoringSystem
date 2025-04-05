//package com.project.health_management

//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity: FlutterActivity()
////
//import android.os.Bundle
//import android.util.Log
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import android.os.Handler
//
//class MainActivity: FlutterActivity() {
//    private val CHANNEL = "pebble_communication"
//    private lateinit var methodChannel: MethodChannel
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//
//        // Send test data every 5 seconds
//        Handler(mainLooper).postDelayed({
//            sendTestDataToFlutter()
//        }, 5000)
//    }
//
//    private fun sendTestDataToFlutter() {
//        val testData = mapOf("data" to "Test data from Android")
//        methodChannel.invokeMethod("receiveData", testData)
//        Log.d("Pebble", "Sent test data to Flutter: $testData")
//    }
//}
package com.project.health_management

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "pebble_channel"
    private lateinit var methodChannel: MethodChannel
    private var healthDataReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "startListeningHealthData") {
                registerPebbleReceiver()
                result.success("Listening for Pebble health data...")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun registerPebbleReceiver() {
        if (healthDataReceiver == null) {
            healthDataReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if ("com.getpebble.action.RECEIVE_DATA" == intent.action) {
                        val data = intent.getByteArrayExtra("data")
                        if (data != null) {
                            val dataString = String(data) // Convert byte array to string
                            Log.d("Pebble", "Health Data Received: $dataString")

                            // Send received data to Flutter
                            methodChannel.invokeMethod("onHealthDataReceived", dataString)
                        }
                    }
                }
            }

            val filter = IntentFilter("com.getpebble.action.RECEIVE_DATA")

            // Set receiver export options for Android 13+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(healthDataReceiver, filter, RECEIVER_EXPORTED)
            } else {
                registerReceiver(healthDataReceiver, filter)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        healthDataReceiver?.let {
            unregisterReceiver(it)
            healthDataReceiver = null
        }
    }
}
