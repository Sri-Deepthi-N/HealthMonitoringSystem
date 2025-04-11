import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Screens/login.dart';
import 'package:health_management/Notification/notification_services.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:health_management/Screens/watch_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';


final FlutterReactiveBle _ble = FlutterReactiveBle();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.containsKey('user_id');
  runApp(MyApp(isLoggedIn: isLoggedIn)
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  bool isLoggedIn = false;
  bool isConnected = false;
  late Stream<ConnectionStateUpdate> _connectionStream;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await authService.getUserData();
    isLoggedIn =widget.isLoggedIn;
    _checkLoginAndConnection();
  }

  Future<void> _checkLoginAndConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id');
    if (isLoggedIn && deviceId != null) {
      _connectionStream = _ble.connectToDevice(id: deviceId);
      _connectionStream.listen((update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          setState(() => isConnected = true);
        } else {
          setState(() => isConnected = false);
        }
      }, onError: (e) {
        setState(() => isConnected = false);
      });
    } else {
      setState(() => isConnected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;
    if (!isLoggedIn) {
      screen = const LoginPage();
    } else if (isConnected) {
      screen = const HomePage();
    } else {
      screen = const BluetoothScreen();
    }
    return MaterialApp(
      home: screen,
    );
  }
}