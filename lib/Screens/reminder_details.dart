import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:health_management/Screens/reminder_form.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  ReminderPageState createState() => ReminderPageState();
}

class ReminderPageState extends State<ReminderPage> {
  List<Map<String, dynamic>> reminders = [];
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
      _loadReminders();

    }
  }

  Future<void> _loadReminders() async {
    if (userId == null) return;
    final data = await DBHelper().getReminders(userId!);
    setState(() {
      reminders = data;
    });
  }

  Future<void> _addReminder(Map<String, dynamic> newReminder) async {
    await DBHelper().insertReminder(
        {
          ...newReminder,
          'user_id': userId,
        });
    _loadReminders();
    _showMessage("Reminder added successfully");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: const Text("Reminders"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: reminders.isEmpty
          ? const Center(child: Text("No Reminders Added"))
          : ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(reminder['Activity']),
              subtitle: Text(
                  "Frequency: ${reminder['Frequency']}\nTime: ${reminder['ReminderTime']}"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newReminder = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReminderFormPage()),
          );

          if (newReminder != null) {
            _addReminder(newReminder);
          }
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
