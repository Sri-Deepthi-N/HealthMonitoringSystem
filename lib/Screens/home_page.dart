import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Provider/user_provider.dart';
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
  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }
  String username ="user";
  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestPermissions();
    final userProvider = Provider.of<UserProvider>(context);
    setState(() {
      username = userProvider.user.username;
    });
  }


  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.location.request();
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
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 50, 0, 0),
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