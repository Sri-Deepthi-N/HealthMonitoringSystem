import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/medicine_form.dart';
import 'package:health_management/Screens/home_page.dart';

class MedicineDetailsPage extends StatefulWidget {
  const MedicineDetailsPage({super.key});

  @override
  MedicineDetailsPageState createState() => MedicineDetailsPageState();
}

class MedicineDetailsPageState extends State<MedicineDetailsPage> {
  List<Map<String, dynamic>> medicines = [];
  int? userId;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final authService = AuthService();
    final userInfo = await authService.getUserData();
    if (userInfo != null) {
      setState(() {
        userId = userInfo['user_id'];
      });
    }
    if (userId != null) {
      _fetchMedicines();
    }
  }

  Future<void> _fetchMedicines() async {
    if (userId == null) return;
    final data = await DBHelper().getMedicines(userId!);
    setState(() {
      medicines = data;
    });
  }

  Future<void> _addMedicine(Map<String, dynamic> medicine) async {
    await DBHelper().insertMedicine({
      ...medicine,
      'user_id': userId,
    });
    _showError("Medicine added successfully");
    _fetchMedicines();
  }

  Future<void> _deleteMedicine(int id) async {
    await DBHelper().deleteMedicine(id);
    _showError("Medicine deleted successfully");
    _fetchMedicines();
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
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: medicines.isEmpty
            ? const Center(child: Text("No medicines added yet.", style: TextStyle(fontSize: 16)))
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMedicine(medicine["id"]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: Colors.black),
                          const SizedBox(width: 5),
                          Text(
                            "Intake: ${medicine["Morning"] == 1 ? "Morning, " : ""}${medicine["Afternoon"] == 1 ? "Afternoon, " : ""}${medicine["Evening"] == 1 ? "Evening, " : ""}${medicine["Night"] == 1 ? "Night" : ""}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 18, color: Colors.black),
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
          final result = await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MedicineFormPage()),
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
