package com.project.health_management

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sri.bluetooth/pair"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val address = call.argument<String>("address")
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            val device = bluetoothAdapter.getRemoteDevice(address)

            when (call.method) {
                "createBond" -> {
                    try {
                        val bonded = device.createBond()
                        result.success(bonded)
                    } catch (e: Exception) {
                        Log.e("Bonding", "Bonding failed", e)
                        result.success(false)
                    }
                }
                "isBonded" -> {
                    result.success(device.bondState == BluetoothDevice.BOND_BONDED)
                }
                else -> result.notImplemented()
            }
        }
    }
}