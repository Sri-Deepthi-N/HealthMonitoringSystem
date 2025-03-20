import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_management/Screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:health_management/Provider/user_provider.dart';
import 'package:health_management/Utils/constants.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  HabitPageState createState() => HabitPageState();
}

class HabitPageState extends State<HabitPage> {
  Map<String, String> _selectedHabits = {
    "Smoking": "No",
    "Drinking": "No",
    "Junk_food": "No",
    "Drugs": "No",
    "Coffee": "No",
    "Tea": "No",
  };

  int? userId;
  int? habitId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
    if (userId != null) {
      _fetchHabits();
    }
  }

  Future<void> _fetchHabits() async {
    if (userId == null) return;
    try {
      final response = await http.get(Uri.parse('${Constants.uri}/habits/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> habits = json.decode(response.body);
        if (habits.isNotEmpty) {
          setState(() {
            habitId = habits.first["id"];
            _selectedHabits = {
              "Smoking": habits.first["Smoking"],
              "Drinking": habits.first["Drinking"],
              "Junk_food": habits.first["Junk_food"],
              "Drugs": habits.first["Drugs"],
              "Coffee": habits.first["Coffee"],
              "Tea": habits.first["Tea"],
            };
          });
        }
      }
    } catch (e) {
      _showError("Error fetching habits: $e");
    }
  }

  Future<void> _saveHabits() async {
    if (userId == null) return;
    final Map<String, dynamic> habitData = {
      "Smoking": _selectedHabits["Smoking"],
      "Drinking": _selectedHabits["Drinking"],
      "Junk_food": _selectedHabits["Junk_food"],
      "Drugs": _selectedHabits["Drugs"],
      "Coffee": _selectedHabits["Coffee"],
      "Tea": _selectedHabits["Tea"],
    };

    try {
      final response = habitId == null
          ? await http.post(
        Uri.parse('${Constants.uri}/habits'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({...habitData, "user_id": userId}),
      )
          : await http.put(
        Uri.parse('${Constants.uri}/habits/$habitId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(habitData),
      );

      if (response.statusCode == 200) {
        if (habitId == null) {
          setState(() {
            habitId = json.decode(response.body)["id"];
          });
        }
        _showError("Habits saved successfully");
      } else {
        _showError("Failed to save habits");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  void _updateHabit(String habit, String value) {
    setState(() {
      _selectedHabits[habit] = value;
    });
    _saveHabits();
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
        title: Text("Habits"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true, // Always show scrollbar
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: _selectedHabits.keys.map((habit) {
                      return HabitTile(
                        habit: habit,
                        selectedValue: _selectedHabits[habit]!,
                        onChanged: (value) => _updateHabit(habit, value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          // Buttons at the bottom
        ],
      ),
    );
  }
}

class HabitTile extends StatelessWidget {
  final String habit;
  final String selectedValue;
  final Function(String) onChanged;

  const HabitTile({super.key,
    required this.habit,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 10,
              children: ["Frequently", "Rarely", "No"].map((option) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: option,
                      groupValue: selectedValue,
                      onChanged: (value) => onChanged(value!),
                    ),
                    Text(option),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}