import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_management/Screens/watch_connection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Screens/Reminder_details.dart';
import 'package:health_management/Screens/activity.dart';
import 'package:health_management/Screens/activity_monitoring.dart';
import 'package:health_management/Screens/doctor_details.dart';
import 'package:health_management/Screens/family_detail.dart';
import 'package:health_management/Screens/habit_page.dart';
import 'package:health_management/Screens/map.dart';
import 'package:health_management/Screens/medical_details.dart';
import 'package:health_management/Screens/medicine_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = [];
  DiscoveredDevice? watch;
  String username = "user";
  //StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  Map<String, String?> healthData = {
    "BP Level": null,
    "Heart Rate": null,
    "Sleep Quality": null,
    "Body Temperature": null,
    "SpO2 Level": null,
    "Steps Taken": null,
    "Calories Burned": null,
    "Respiration Rate": null,
    "Hydration Level": null,
    "Blood Glucose": null,
    "Stress Level": null,
  };


  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestPermissions();
    _checkExistingConnection();
    _loadUserData();
  }

  void _loadUserData() async {
    final authService = AuthService();
    final userInfo = await authService.getUserData();

    if (userInfo != null) {
      setState(() {
        username = userInfo['UserName'] ?? 'User';
        userId = userInfo['user_id']?.toString() ?? '';
      });
    }
  }

  String userId = "";


  //final GoogleFitService _googleFitService = GoogleFitService();
  // List<Map<String, dynamic>> _healthData = [];
  //
  // Future<void> _fetchData() async {
  //   var healthData = await _googleFitService.fetchHealthData();
  //   setState(() {
  //     _healthData = healthData
  //         .map((data) => {
  //       'type': data.typeString,
  //       'value': data.value.toString(),
  //       'date': data.dateFrom.toString(),
  //     })
  //         .toList();
  //   });
  // }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.scheduleExactAlarm.request();

  }

  void _checkExistingConnection() {
    if (watch != null) {
      //readDataFromDevice(watch!);
    }
  }

  // void scanForDevices() {
  //   setState(() {
  //     devices = [];
  //   });
  //   final scanSubscription = flutterReactiveBle.scanForDevices(
  //     withServices: [],
  //     scanMode: ScanMode.lowLatency,
  //   ).listen((device) {
  //     if (!devices.any((d) => d.id == device.id) && device.name.isNotEmpty) {
  //       setState(() {
  //         devices.add(device);
  //       });
  //     }
  //   });
  //   Future.delayed(const Duration(seconds: 10), () {
  //     scanSubscription.cancel(); // Stop scanning
  //     _showDevicesPopup();
  //   });
  // }
  //
  // void _showDevicesPopup() {
  //   if (devices.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("No devices found. Try again.")),
  //     );
  //     return;
  //   }
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Available Devices"),
  //         content: SizedBox(
  //           width: double.maxFinite,
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: devices.length,
  //             itemBuilder: (context, index) {
  //               final device = devices[index];
  //               return ListTile(
  //                 title: Text(device.name),
  //                 onTap: () {
  //                   Navigator.pop(context); // Close popup before connecting
  //                   connectToDevice(device);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Close"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void connectToDevice(DiscoveredDevice device) {
  //   _connectionSubscription?.cancel();
  //   print("Devices $device");
  //   _connectionSubscription = flutterReactiveBle.connectToDevice(
  //     id: device.id,
  //     connectionTimeout: const Duration(seconds: 10),
  //   ).listen((connectionState) {
  //     print("Devices $connectionState");
  //     if (connectionState.connectionState == DeviceConnectionState.connected) {
  //       setState(() {
  //         watch = device;
  //         print("Devices $connectionState");
  //       });
  //       readDataFromDevice(device);
  //     } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
  //       print("Device disconnected. Reconnect attempt in 5 seconds...");
  //       Future.delayed(const Duration(seconds: 5), () {
  //         if (watch != null) {
  //           connectToDevice(watch!);
  //         }
  //       });
  //     }
  //   });
  // }
  //
  //
  // void disconnectDevice() {
  //   if (_connectionSubscription != null) {
  //     _connectionSubscription!.cancel();
  //     _connectionSubscription = null;
  //   }
  //   if (watch != null) {
  //     setState(() {
  //       watch = null;
  //     });
  //   }
  // }
  //
  // void readDataFromDevice(DiscoveredDevice device) async {
  //   try {
  //     List<DiscoveredService> services = await flutterReactiveBle.discoverServices(device.id);
  //     print("🔍 Discovered Services:");
  //
  //     for (var service in services) {
  //       print("📡 Service ID: ${service.serviceId}");
  //
  //       for (var characteristic in service.characteristics) {
  //         print("➡️ Characteristic ID: ${characteristic.characteristicId}");
  //
  //         try {
  //           final qualifiedCharacteristic = QualifiedCharacteristic(
  //             characteristicId: characteristic.characteristicId,
  //             serviceId: service.serviceId,
  //             deviceId: device.id,
  //           );
  //
  //           List<int> rawData = await flutterReactiveBle.readCharacteristic(qualifiedCharacteristic);
  //
  //           if (rawData.isNotEmpty) {
  //             String receivedData = rawData.map((e) => e.toRadixString(16).padLeft(2, '0')).join(" ");
  //             print("✅ Data from ${characteristic.characteristicId}: $receivedData");
  //           } else {
  //             print("⚠️ No data received from ${characteristic.characteristicId}");
  //           }
  //         } catch (e) {
  //           print("❌ Error reading ${characteristic.characteristicId}: $e");
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ Service Discovery Error: $e");
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text("Hi, $username!"),
        actions: [
          // if (watch != null)
          //   IconButton(
          //     icon: const Icon(Icons.watch_off, color: Colors.white),
          //     onPressed: disconnectDevice,
          //   ),
          if (watch == null)
          IconButton(
            icon: const Icon(Icons.watch_rounded, color: Colors.white),
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Watch()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GoogleMapScreen()),
              );
            },
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/user_profile.jpg'),
            ),
            onPressed: () {
              _showProfileLogoutOptions(context);
            },
          ),
        ],
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/user_profile.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Hi, $username!",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.history, "Medical History", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MedicalHistoryPage()),
              );
            }),
            _buildDrawerItem(Icons.monitor_heart, "Activity Monitoring", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ActivityMonitoringPage()),
              );
            }),
            _buildDrawerItem(Icons.family_restroom, "Family Details", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FamilyDetailsPage()),
              );
            }),
            _buildDrawerItem(Icons.local_hospital, "Doctor Details", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DoctorDetailsPage()),
              );
            }),
            _buildDrawerItem(Icons.medication, "Medicine Details", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MedicineDetailsPage()),
              );
            }),
            _buildDrawerItem(Icons.track_changes, "Habit", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HabitPage()),
              );
            }),
            _buildDrawerItem(Icons.notifications, "Remainder", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ReminderPage()),
              );
            }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Health Parameters",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  children: [
                    _buildHealthParameter(
                      "BP Level", "120/80 mmHg", Icons.favorite, Colors.red, () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }),
                    _buildHealthParameter(
                      "Heart Rate", "72 bpm", Icons.monitor_heart, Colors.blue,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "Sleep Quality", "Good (7.5 hrs)", Icons.bedtime, Colors.purple,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "Body Temperature", "98.6°F", Icons.thermostat, Colors.orange,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "SpO2 Level", "98%", Icons.air, Colors.green,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "Steps Taken", "5,420 steps", Icons.directions_walk, Colors.brown,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "Calories Burned", "320 kcal", Icons.local_fire_department, Colors.redAccent,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "Respiration Rate", "16 breaths/min", Icons.air, Colors.teal,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "Hydration Level", "75%", Icons.local_drink, Colors.cyan,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(
                      "Blood Glucose", "95 mg/dL", Icons.bloodtype, Colors.deepOrange,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                    _buildHealthParameter(""
                      "Stress Level", "Moderate", Icons.sentiment_neutral, Colors.grey,() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HealthParametersPage()),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileLogoutOptions(BuildContext context) {
    final RenderBox appBarBox = context.findRenderObject() as RenderBox;
    final Offset position = appBarBox.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx + appBarBox.size.width - 50, position.dy + 50, 0, 0),
      items: [
        PopupMenuItem(
          child: const Text("My Profile"),
          onTap: () {},
        ),
        PopupMenuItem(
          child: const Text("Logout"),
          onTap: () {
            signOutUser(context);
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildHealthParameter(String title, String value, IconData icon, Color iconColor, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
        onTap: onTap,
      ),
    );
  }
}


// 2
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final flutterReactiveBle = FlutterReactiveBle();
//   List<DiscoveredDevice> devices = [];
//   DiscoveredDevice? watch;
//   StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
//   Map<String, String?> healthData = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//   }
//
//   Future<void> _requestPermissions() async {
//     await Permission.bluetoothScan.request();
//     await Permission.bluetoothConnect.request();
//     await Permission.location.request();
//   }
//
//   void scanForDevices() {
//     setState(() {
//       devices = [];
//     });
//
//     final scanSubscription = flutterReactiveBle.scanForDevices(
//       withServices: [],
//       scanMode: ScanMode.lowLatency,
//     ).listen((device) {
//       if (!devices.any((d) => d.id == device.id) && device.name.isNotEmpty) {
//         setState(() {
//           devices.add(device);
//         });
//       }
//     });
//
//     Future.delayed(const Duration(seconds: 10), () {
//       scanSubscription.cancel();
//       _showDevicesPopup();
//     });
//   }
//
//   void _showDevicesPopup() {
//     if (devices.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No devices found. Try again.")),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Available Devices"),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: devices.length,
//               itemBuilder: (context, index) {
//                 final device = devices[index];
//                 return ListTile(
//                   title: Text(device.name),
//                   onTap: () {
//                     Navigator.pop(context);
//                     connectToDevice(device);
//                   },
//                 );
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void connectToDevice(DiscoveredDevice device) {
//     _connectionSubscription?.cancel();
//
//     _connectionSubscription = flutterReactiveBle.connectToDevice(
//       id: device.id,
//       connectionTimeout: const Duration(seconds: 10),
//     ).listen((connectionState) {
//       if (connectionState.connectionState == DeviceConnectionState.connected) {
//         setState(() {
//           watch = device;
//         });
//         discoverServices(device);
//       } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
//         print("Device disconnected. Reconnecting...");
//         Future.delayed(const Duration(seconds: 5), () {
//           connectToDevice(device);
//         });
//       }
//     });
//   }
//
//   void discoverServices(DiscoveredDevice device) async {
//     try {
//       List<DiscoveredService> services = await flutterReactiveBle.discoverServices(device.id);
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           readCharacteristic(device.id, service.serviceId, characteristic.characteristicId);
//         }
//       }
//     } catch (e) {
//       print("Error discovering services: $e");
//     }
//   }
//
//   void readCharacteristic(String deviceId, Uuid serviceId, Uuid characteristicId) async {
//     try {
//       final qualifiedCharacteristic = QualifiedCharacteristic(
//         characteristicId: characteristicId,
//         serviceId: serviceId,
//         deviceId: deviceId,
//       );
//
//       List<int> rawData = await flutterReactiveBle.readCharacteristic(qualifiedCharacteristic);
//       String hexData = rawData.map((e) => e.toRadixString(16).padLeft(2, '0')).join(" ");
//       print("Raw Data: $hexData");
//
//       // Convert and store data
//       String parsedData = _parseSmartwatchData(hexData);
//       setState(() {
//         healthData[characteristicId.toString()] = parsedData;
//       });
//     } catch (e) {
//       print("Error reading characteristic: $e");
//     }
//   }
//
//   String _parseSmartwatchData(String hexData) {
//     try {
//       List<int> bytes = hexData.split(" ").map((e) => int.parse(e, radix: 16)).toList();
//       return utf8.decode(bytes);
//     } catch (e) {
//       return "Unknown Data Format";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Smartwatch Data"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: scanForDevices,
//           ),
//         ],
//       ),
//       body: ListView(
//         children: healthData.entries.map((entry) {
//           return ListTile(
//             title: Text(entry.key),
//             subtitle: Text(entry.value ?? "No data"),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
