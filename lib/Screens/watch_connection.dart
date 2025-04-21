import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterReactiveBle _ble = FlutterReactiveBle();
const platform = MethodChannel("com.sri.bluetooth/pair");

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  BluetoothScreenState createState() => BluetoothScreenState();
}

class BluetoothScreenState extends State<BluetoothScreen> {
  final List<DiscoveredDevice> _devices = [];
  String? _savedDeviceId;
  String? _savedDeviceName;

  late final StreamSubscription<DiscoveredDevice> _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
    _tryReconnectSavedDevice();
  }

  Future<void> _checkPermissionsAndScan() async {
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    _startScan();
  }

  void _startScan() {
    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      if (!mounted) return;
      if (!_devices.any((d) => d.id == device.id) && device.name.isNotEmpty) {
        setState(() {
          _devices.add(device);
        });
      }
    });
  }

  Future<void> _tryReconnectSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    _savedDeviceId = prefs.getString('device_id');
    _savedDeviceName = prefs.getString('device_name');
    if (_savedDeviceId != null && _savedDeviceName != null) {
      _connectToDevice(_savedDeviceId!, _savedDeviceName!);
    }
  }

  Future<void> _connectToDevice(String deviceId, String name) async {
    _connectionSubscription?.cancel(); // cancel previous connection if any
    _connectionSubscription = _ble.connectToDevice(id: deviceId).listen(
          (state) async {
        if (!mounted) return;
        if (state.connectionState == DeviceConnectionState.connected) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('device_id', deviceId);
          await prefs.setString('device_name', name);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Connected to $name")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
      onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Connection failed: $e")),
          );
        }
      },
    );
  }

  Future<void> _onDeviceTap(DiscoveredDevice device) async {
    final isBonded = await platform.invokeMethod<bool>(
      "isBonded",
      {"address": device.id},
    );

    if (isBonded == true) {
      _connectToDevice(device.id, device.name);
    } else {
      final result = await platform.invokeMethod<bool>(
        "createBond",
        {"address": device.id},
      );
      if (result == true) {
        _connectToDevice(device.id, device.name);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pairing failed")),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Devices"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return ListTile(
            title: Text(device.name),
            onTap: () => _onDeviceTap(device),
          );
        },
      ),
    );
  }
}
