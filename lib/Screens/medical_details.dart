import 'package:flutter/material.dart';
import 'package:health_management/Authentication/Backend.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Screens/medical_form.dart';
import 'package:health_management/Screens/home_page.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  MedicalHistoryPageState createState() => MedicalHistoryPageState();
}

class MedicalHistoryPageState extends State<MedicalHistoryPage> {
  Map<String, dynamic> medicalHistory = {
    "Condition": "Nil",
    "Treatment": "Nil",
    "Tablet": "Nil",
  };

  int? userId;
  int? historyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserAndHistory();
  }

  Future<void> _loadUserAndHistory() async {
    final authService = AuthService();
    final userInfo = await authService.getUserData();
    if (userInfo != null) {
      userId = userInfo['user_id'];
      await _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    if (userId == null) return;

    final List<Map<String, dynamic>> historyList = await DBHelper().getMedicalDetails(userId!);
    if (historyList.isNotEmpty) {
      final data = historyList.first;
      setState(() {
        historyId = data["id"];
        medicalHistory = {
          "Condition": data["Condition"],
          "Treatment": data["Treatment"],
          "Tablet": data["Tablet"],
        };
      });
    }
  }

  Future<void> _updateHistory(Map<String, dynamic> historyData) async {
    if (userId == null) return;

    final Map<String, dynamic> dataWithUser = {
      "Condition": historyData["Condition"],
      "Treatment": historyData["Treatment"],
      "Tablet": historyData["Tablet"],
      "user_id": userId,
    };

    if (historyId == null) {
      int insertedId = await DBHelper().insertMedical(dataWithUser);
      setState(() {
        historyId = insertedId;
      });
    } else {
      await DBHelper().updateMedical(historyId!, dataWithUser);
    }

    _fetchHistory();
    _showMessage("History saved successfully");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newHistory = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HealthDetailsFormPage()),
              );
              if (newHistory != null) {
                _updateHistory(newHistory);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: medicalHistory.isEmpty
            ? const Center(child: Text("No medical history added yet."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text("Condition", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Value", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...medicalHistory.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key, style: const TextStyle(fontSize: 14)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(entry.value.toString(), style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
