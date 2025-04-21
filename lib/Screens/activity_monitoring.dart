import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:health_management/Screens/map.dart';
import 'package:health_management/Screens/activity.dart';
import 'package:health_management/Screens/google_fit.dart';

class ActivityMonitoringPage extends StatefulWidget {
  const ActivityMonitoringPage({super.key});

  @override
  ActivityMonitoringPageState createState() => ActivityMonitoringPageState();
}

class ActivityMonitoringPageState extends State<ActivityMonitoringPage> {
  String? _address;
  bool _isLoading = true;
  final GoogleFitService _googleFitService = GoogleFitService();
  bool isLoading = false;
  String? errorMessage;
  Map<String, String?> healthData = {
    "Steps Taken": null,
    "Calories Burned": null,
    "Distance Travelled" : null,
  };


  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      setState(() {
        _address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(", ");

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _address = "Error: $e";
        _isLoading = false;
      });
    }
  }

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
        _googleFitService.getCaloriesBurned(accessToken),
        _googleFitService.getDistance(accessToken),
      ]);

      setState(() {
        healthData = {
          "Steps Taken": results[0],
          "Calories Burned": results[1],
          "Distance Travelled" : results[2],
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
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchHealthData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Activity Monitoring"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityCard(
              context,
              icon: Icons.directions_walk,
              title: "Steps Taken",
              value: healthData["Steps Taken"] ?? "No Data",
              iconColor: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityPage(title: "Steps Taken"),
                  ),
                );
              },
            ),
            _buildActivityCard(
              context,
              icon: Icons.local_fire_department,
              title: "Calories Burned",
              value: healthData["Calories Burned"] ?? "No Data",
              iconColor: Colors.orangeAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityPage(title: "Calories Burned"),
                  ),
                );
              },
            ),
            _buildActivityCard(
              context,
              icon: Icons.directions_run,
              title: "Distance Traveled",
              value: healthData["Distance Travelled"] ?? "No Data",
              iconColor: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityPage(title: "Distance Traveled"),
                  ),
                );
              },
            ),
            _buildActivityCard(
              context,
              icon: Icons.location_on,
              title: "Current Location",
              value: _isLoading ? "" : _address ?? "Unknown location",
              iconColor: Colors.red,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GoogleMapScreen()),
                );
              },
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color iconColor,
        required VoidCallback onTap,
        bool isLoading = false,
      }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 30, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: isLoading
            ? const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            : Text(value),
        onTap: onTap,
      ),
    );
  }
}
