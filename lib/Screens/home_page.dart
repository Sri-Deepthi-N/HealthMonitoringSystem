import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_management/Authentication/Backend.dart';
import 'package:health_management/Screens/google_fit.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> devices = [];
  String username = "user";
  bool isConnected = false;
  final GoogleFitService _googleFitService = GoogleFitService();
  Timer? refreshTimer;
  bool isLoading = false;
  String? errorMessage;
  String userId = "";
  String? deviceId;

  Map<String, String?> healthData = {
    "BP Level": null,
    "Heart Rate": null,
    "Sleep Quality": null,
    "Body Temperature": null,
    "SpO2 Level": null,
    "Steps Taken": null,
    "Calories Burned": null,
    "Blood Glucose": null,
    "Distance Travelled" : null,
  };

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _requestPermissions();
    await _checkConnection();
    _loadUserData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.activityRecognition.request();
    await Permission.sensors.request();
    await Permission.location.request();
    await Permission.scheduleExactAlarm.request();
  }

  Future<void> _checkConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('device_id');
    deviceId = savedId;
    if (savedId == null) {
      setState(() => isConnected = false);
      return;
    }
    else {
      setState(() => isConnected = true);
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

  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }

  void _startAutoRefresh() {
    _fetchHealthData();
    refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchHealthData();
    });
  }

  Future<void> _addHealth(Map<String, dynamic> health, String name ) async {
    final dbHelper = DBHelper();
    await dbHelper.insertHealthData(name, {...health, 'user_id': userId});
  }

  List<Map<String, dynamic>> healthDataFromDB = [];

  Future<void> _fetchHealthData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final accessToken = await _googleFitService.getAccessToken();
      if (accessToken == null) {
        setState(() {
          errorMessage = 'Please sign in with Google to access health data';
        });
        return;
      }

      final results = await Future.wait([
        _googleFitService.getSteps(accessToken),
        _googleFitService.getHeartRate(accessToken),
        _googleFitService.getBloodPressure(accessToken),
        _googleFitService.getSleepData(accessToken),
        _googleFitService.getBodyTemperature(accessToken),
        _googleFitService.getOxygenSaturation(accessToken),
        _googleFitService.getCaloriesBurned(accessToken),
        _googleFitService.getBloodGlucose(accessToken),
        _googleFitService.getDistance(accessToken),
      ]);

      final now = DateTime.now();
      final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Save to DB
      await _addHealth({"value": results[1], "date": date, "time": time}, "HeartRate");
      await _addHealth({"systolic": results[2].split("/"), "diastolic": results[2].split("/"), "date": date, "time": time}, "BPLevel");
      await _addHealth({"quality": results[3], "date": date, "time": time}, "SleepQuality");
      await _addHealth({"value": results[4], "date": date, "time": time}, "BodyTemperature");
      await _addHealth({"percentage": results[5], "date": date, "time": time}, "SpO2Level");
      await _addHealth({"steps": results[0], "date": date, "time": time}, "StepsTaken");
      await _addHealth({"calories": results[6], "date": date, "time": time}, "CaloriesBurned");
      await _addHealth({"glucose": results[7], "date": date, "time": time}, "BloodGlucose");
      await _addHealth({"distance": results[8], "date": date, "time": time}, "DistanceTravelled");
      setState(() {
        healthData = {
          "BP Level": results[2],
          "Heart Rate": results[1],
          "Sleep Quality": results[3],
          "Body Temperature": results[4],
          "SpO2 Level": results[5],
          "Steps Taken": results[0],
          "Calories Burned": results[6],
          "Blood Glucose": results[7],
          "Distance Travelled" : results[8],
        };
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load health data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              onPressed: () {},
            ),
          if (isConnected == false)
            IconButton(
              icon: const Icon(Icons.watch_rounded, color: Colors.white),
              onPressed: () {
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
                MaterialPageRoute(
                    builder: (context) => const ActivityMonitoringPage()),
              );
            }),
            _buildDrawerItem(Icons.family_restroom, "Family Details", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const FamilyDetailsPage()),
              );
            }),
            _buildDrawerItem(Icons.local_hospital, "Doctor Details", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DoctorDetailsPage()),
              );
            }),
            _buildDrawerItem(Icons.medication, "Medicine Details", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MedicineDetailsPage()),
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

            if (isLoading)
              const LinearProgressIndicator(),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: RefreshIndicator(
                  onRefresh: _fetchHealthData,
                  child: ListView(
                    children: [
                      _buildHealthParameter(
                          "BP Level",
                          healthData["BP Level"] ?? "No data",
                          Icons.favorite,
                          Colors.red,
                              () => _navigateToHealthDetails("BP Level")
                      ),
                      _buildHealthParameter(
                          "Heart Rate",
                          healthData["Heart Rate"] ?? "No data",
                          Icons.monitor_heart,
                          Colors.blue,
                              () => _navigateToHealthDetails("Heart Rate")
                      ),
                      _buildHealthParameter(
                          "Sleep Quality",
                          healthData["Sleep Quality"] ?? "No data",
                          Icons.bedtime,
                          Colors.purple,
                              () => _navigateToHealthDetails("Sleep Quality")
                      ),
                      _buildHealthParameter(
                          "Body Temperature",
                          healthData["Body Temperature"] ?? "No data",
                          Icons.thermostat,
                          Colors.orange,() => _navigateToHealthDetails("Body Temperature")
                      ),
                      _buildHealthParameter(
                          "SpO2 Level",
                          healthData["SpO2 Level"] ?? "No data",
                          Icons.air,
                          Colors.green,
                              () => _navigateToHealthDetails("SpO2 Level")
                      ),
                      _buildHealthParameter(
                          "Steps Taken",
                          healthData["Steps Taken"] ?? "No data",
                          Icons.directions_walk,
                          Colors.brown,
                              () => _navigateToHealthDetails("Steps Taken")
                      ),
                      _buildHealthParameter(
                          "Calories Burned",
                          healthData["Calories Burned"] ?? "No data",
                          Icons.local_fire_department,
                          Colors.redAccent,
                              () => _navigateToHealthDetails("Calories Burned")
                      ),
                      _buildHealthParameter(
                          "Distance Travelled",
                          healthData["Distance Travelled"] ?? "No data",
                          Icons.directions_run,
                          Colors.purple,
                              () => _navigateToHealthDetails("Distance Travelled")
                      ),
                      _buildHealthParameter(
                          "Blood Glucose",
                          healthData["Blood Glucose"] ?? "No data",
                          Icons.bloodtype,
                          Colors.deepOrange,
                              () => _navigateToHealthDetails("Blood Glucose")
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHealthDetails(String parameter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityPage(title: parameter),
      ),
    );
  }
  void _showProfileLogoutOptions(BuildContext context) {
    final RenderBox appBarBox = context.findRenderObject() as RenderBox;
    final Offset position = appBarBox.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx + appBarBox.size.width - 50, position.dy + 50, 0, 0),
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

  Widget _buildHealthParameter(String title, String value, IconData icon,
      Color iconColor, VoidCallback onTap) {
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