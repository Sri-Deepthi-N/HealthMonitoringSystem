// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
//
// class Watch extends StatefulWidget {
//   const Watch({super.key});
//
//   @override
//   WatchState createState() => WatchState();
// }
//
// class WatchState extends State<Watch> {
//   static const platform = MethodChannel('pebble_communication');
//   String _receivedData = "No data yet";
//
//   Future<void> sendDataToPebble(String message) async {
//     try {
//       await platform.invokeMethod('sendData', {'message': message});
//     } on PlatformException catch (e) {
//       print("Failed to send data: '${e.message}'.");
//     }
//   }
//
//   Future<void> receiveDataFromPebble() async {
//     print("MethodChannel object: $platform"); // Debugging platform instance
//
//     platform.setMethodCallHandler((MethodCall call) async {
//       print("Received method call: ${call.method}"); // Debugging method call
//
//       if (call.method == "receiveData") {
//         setState(() {
//           _receivedData = call.arguments['data'];
//         });
//         print("Data received from Pebble: $_receivedData"); // Debugging received data
//       }
//     });
//
//     print("No Error ${platform}");
//   }
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     receiveDataFromPebble();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//    // print("Watch Connected");
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text("Flutter-Pebble Integration")),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Received from Pebble: $_receivedData"),
//               ElevatedButton(
//                 onPressed: () => sendDataToPebble("Hello Pebble"),
//                 child: Text("Send Data to Pebble"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Watch extends StatefulWidget {
  const Watch({super.key});

  @override
  WatchState createState() => WatchState();
}

class WatchState extends State<Watch> {
  static const platform = MethodChannel('pebble_communication');
  String _receivedData = "No data yet";
  bool _isPebbleConnected = false;

  Future<void> checkPebbleConnection() async {
    try {
      final bool result = await platform.invokeMethod('isPebbleConnected');
      print("Result $result");
      setState(() {
        _isPebbleConnected = result;
      });
    } on PlatformException catch (e) {
      print("Failed to check Pebble connection: '${e.message}'.");
    }
  }

  Future<void> sendDataToPebble(String message) async {
    try {
      await platform.invokeMethod('sendData', {'message': message});
    } on PlatformException catch (e) {
      print("Failed to send data: '${e.message}'.");
    }
  }

  Future<void> receiveDataFromPebble() async {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == "receiveData") {
        setState(() {
          _receivedData = call.arguments['data'];
        });
        print("Data received from Pebble: $_receivedData");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkPebbleConnection();
    receiveDataFromPebble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pebble Watch Data")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pebble Connected: $_isPebbleConnected"),
            Text("Received Data: $_receivedData"),
            ElevatedButton(
              onPressed: () => sendDataToPebble("Hello from Flutter"),
              child: Text("Send Data to Pebble"),
            ),
          ],
        ),
      ),
    );
  }
}
