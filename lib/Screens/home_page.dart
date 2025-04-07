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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = [];
  String username = "user";
  bool isConnected = false;

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
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _requestPermissions();
    await _checkConnection();
    _loadUserData();
  }

  Future<void> _checkConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('device_id');
    if (savedId == null) {
      setState(() => isConnected = false);
      return;
    }
    else {
      setState(() => isConnected = true);
      await _readSmartwatchData(savedId);

    }
  }

  Future<void> _readSmartwatchData(String deviceId) async {
    final characteristicMap = {
      '0000ae42-0000-1000-8000-00805f9b34fb': 'HeartRate',
      'f0020002-0451-4000-b000-000000000000': 'BloodPressure',
      'f0030002-0451-4000-b000-000000000000': 'SpO2',
      'f0080002-0451-4000-b000-000000000000': 'Temperature',
      '0000fec8-0000-1000-8000-00805f9b34fb': 'Steps',
    };
    final services = await _ble.discoverServices(deviceId);

    for (final service in services) {
      for (final char in service.characteristics) {
        final uuid = char.characteristicId;

        if (characteristicMap.containsKey(uuid)) {
          final keyName = characteristicMap[uuid]!;

          try {
            await _ble.subscribeToCharacteristic(
              QualifiedCharacteristic(
                characteristicId: char.characteristicId,
                serviceId: char.serviceId,
                deviceId: deviceId,
              ),
            ).listen((value) {
              final hex = value.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
              final stringValue = utf8.decode(value, allowMalformed: true);
              print("✅ $keyName -> $hex | $stringValue");
              print("Char123 $characteristicMap");

            });
          } catch (e) {
            print("❌ Could not subscribe to $keyName: $e");
          }
        }
      }
    }
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

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();

  }

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
          if (isConnected == true)
            IconButton(
              icon: const Icon(Icons.watch_off, color: Colors.white),
              onPressed: (){},
            ),
          if (isConnected == false)
          IconButton(
            icon: const Icon(Icons.watch_rounded, color: Colors.white),
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BluetoothScreen()),
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
