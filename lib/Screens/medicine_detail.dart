import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:health_management/Provider/user_provider.dart';
import 'dart:convert';
import 'package:health_management/Screens/medicine_form.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:health_management/Utils/constants.dart';

class MedicineDetailsPage extends StatefulWidget {
  const MedicineDetailsPage({super.key});

  @override
  MedicineDetailsPageState createState() => MedicineDetailsPageState();
}

class MedicineDetailsPageState extends State<MedicineDetailsPage> {
  List<Map<String, dynamic>> medicines = [];
  int? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
    if (userId != null) {
      _fetchMedicines();
    }
  }

  Future<void> _fetchMedicines() async {
    if (userId == null) return;
    try {
      final response = await http.get(Uri.parse('${Constants.uri}/medicine/$userId'));

      if (response.statusCode == 200) {
        setState(() {
          medicines = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _showError("Failed to load medicines");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  Future<void> _addMedicine(Map<String, dynamic> medicine) async {
    if (userId == null) return;
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/medicine'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({...medicine, "user_id": userId}),
      );
      if (response.statusCode == 200) {
        _fetchMedicines();
      } else {
        _showError("Failed to add medicine");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  Future<void> _deleteMedicine(int id) async {
    try {
      final response = await http.delete(Uri.parse('${Constants.uri}/medicine/$id'));
      if (response.statusCode == 200) {
        _fetchMedicines();
      } else {
        _showError("Failed to delete medicine");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Details"),
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
        child: medicines.isEmpty
            ? const Center(
          child: Text("No medicines added yet.",
              style: TextStyle(fontSize: 16)),
        )
            : Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          scrollbarOrientation: ScrollbarOrientation.right,
          child: ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            medicine["MedicineName"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteMedicine(medicine["id"]);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 18, color: Colors.black),
                          const SizedBox(width: 5),
                          Text(
                            "Intake: ${medicine["Morning"] == 1? "Morning," : ""} ${medicine["Afternoon"] == 1? "Afternoon," : ""} ${medicine["Evening"] == 1? "Evening," : ""} ${medicine["Night"] == 1? "Night" : ""}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.restaurant,
                              size: 18, color: Colors.black),
                          const SizedBox(width: 5),
                          Text(
                            "Food: ${medicine["IntakeTime"]}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicineFormPage(),
            ),
          );

          if (result != null) {
            _addMedicine(result);
          }
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}