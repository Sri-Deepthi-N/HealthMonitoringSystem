import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:health_management/Screens/map.dart';
import 'package:health_management/Screens/activity.dart';

class ActivityMonitoringPage extends StatefulWidget {
  const ActivityMonitoringPage({super.key});

  @override
  ActivityMonitoringPageState createState() => ActivityMonitoringPageState();
}

class ActivityMonitoringPageState extends State<ActivityMonitoringPage> {
  String? _address;
  bool _isLoading = true;

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

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _getCurrentLocation();
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
              value: "5000",
              iconColor: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthParametersPage(),
                  ),
                );
              },
            ),
            _buildActivityCard(
              context,
              icon: Icons.local_fire_department,
              title: "Calories Burned",
              value: "250 kcal",
              iconColor: Colors.orangeAccent,
              onTap: () {},
            ),
            _buildActivityCard(
              context,
              icon: Icons.directions_run,
              title: "Distance Traveled",
              value: "3.5 km",
              iconColor: Colors.purple,
              onTap: () {},
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