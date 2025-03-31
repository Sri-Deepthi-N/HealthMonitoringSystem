import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:health_management/Provider/user_provider.dart';
import 'dart:convert';
import 'package:health_management/Screens/medical_form.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:health_management/Utils/constants.dart';
class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  MedicalHistoryPageState createState() => MedicalHistoryPageState();
}

class MedicalHistoryPageState extends State<MedicalHistoryPage> {
  Map<String, dynamic> medicalHistory={
    "Condition" :"Nil",
    "Height" : 0,
    "Weight" : 0,
    "Age" : 0,
    "Treatment" :"Nil",
    "Tablet" :"Nil",
  };

  int? userId;
  int? historyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
    if (userId != null) {
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    if (userId == null) return;
    try {
      final response = await http.get(Uri.parse('${Constants.uri}/medicaldetails/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> history = json.decode(response.body);
        if (history.isNotEmpty) {
          setState(() {
            historyId = history.first["id"];
            medicalHistory = {
              "Condition": history.first["Condition"],
              "Height": history.first["Height"],
              "Weight": history.first["Weight"],
              "Age": history.first["Age"],
              "Treatment": history.first["Treatment"],
              "Tablet": history.first["Tablet"],
            };
          });
        }
      }
    } catch (e) {
      _showError("Error fetching history: $e");
    }
  }

  Future<void> _updateHistory(Map<String,dynamic> historyData) async {
    if (userId == null) return;
    try {
      final response = historyId == null
          ? await http.post(
        Uri.parse('${Constants.uri}/medicaldetails'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({...historyData, "user_id": userId}),
      )
          : await http.put(
        Uri.parse('${Constants.uri}/medicaldetails/$historyId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(historyData),
      );
      if (response.statusCode == 200) {
        if (historyId == null) {
          setState(() {
            historyId = json.decode(response.body)["id"];
          });
          _fetchHistory();
        }
        _showError("History saved successfully");
      } else {
        _showError("Failed to save history");
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
        title: const Text("Medical History"),
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
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text("Condition", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Value", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: medicalHistory.entries.map(
                  (entry) {
                return DataRow(
                  cells: [
                    DataCell(Text(entry.key)),
                    DataCell(Text(entry.value.toString())),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ),

    );
  }
}