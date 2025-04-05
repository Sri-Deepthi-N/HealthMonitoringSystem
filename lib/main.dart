import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Screens/login.dart';
import 'package:health_management/Screens/signup.dart';
import 'package:health_management/Notification/notification_services.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await authService.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: widget.isLoggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   static const platform = MethodChannel('pebble_channel');
//   String receivedData = "Waiting for Pebble health data...";
//
//   @override
//   void initState() {
//     super.initState();
//     startListeningHealthData();
//   }
//
//   Future<void> startListeningHealthData() async {
//     try {
//       final String result = await platform.invokeMethod('startListeningHealthData');
//       print("Flutter1234: ${platform.name}");
//
//       // Listen for data from Android
//       platform.setMethodCallHandler((call) async {
//         if (call.method == "onHealthDataReceived") {
//           setState(() {
//             receivedData = call.arguments.toString();
//           });
//           print("Flutter: Received Pebble Data: $receivedData");
//         }
//       });
//     } on PlatformException catch (e) {
//       print("Flutter: Failed to start listening: '${e.message}'.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text("Pebble Health Data")),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               receivedData,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
