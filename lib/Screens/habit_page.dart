import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/home_page.dart';

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
      _fetchHabits();
    }
  }

  Future<void> _fetchHabits() async {
    if (userId == null) return;
    try {
      final data = await DBHelper().getHabit(userId!);
      if (data != null) {
        setState(() {
          habitId = data["id"];
          _selectedHabits = {
            "Smoking": data["Smoking"],
            "Drinking": data["Drinking"],
            "Junk_food": data["Junk_food"],
            "Drugs": data["Drugs"],
            "Coffee": data["Coffee"],
            "Tea": data["Tea"],
          };
        });
      }
    } catch (e) {
      _showError("Error fetching habits: $e");
    }
  }

  Future<void> _saveHabits() async {
    if (userId == null) return;
    final Map<String, dynamic> habitData = {
      "user_id": userId,
      "Smoking": _selectedHabits["Smoking"],
      "Drinking": _selectedHabits["Drinking"],
      "Junk_food": _selectedHabits["Junk_food"],
      "Drugs": _selectedHabits["Drugs"],
      "Coffee": _selectedHabits["Coffee"],
      "Tea": _selectedHabits["Tea"],
    };

    try {
      if (habitId == null) {
        final id = await DBHelper().insertHabit(habitData);
        setState(() {
          habitId = id;
        });
      } else {
        await DBHelper().updateHabit(habitId!, habitData);
      }
      _showError("Habits saved successfully");
    } catch (e) {
      _showError("Error saving habits: $e");
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text("Habits"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ],
        ),
      ),
    );
  }
}

class HabitTile extends StatelessWidget {
  final String habit;
  final String selectedValue;
  final Function(String) onChanged;

  const HabitTile({
    super.key,
    required this.habit,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
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
