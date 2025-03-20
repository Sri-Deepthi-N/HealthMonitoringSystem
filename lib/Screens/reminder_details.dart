import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:health_management/Screens/home_page.dart';
import 'dart:convert';
import 'package:health_management/Screens/reminder_form.dart';
import 'package:provider/provider.dart';
import 'package:health_management/Provider/user_provider.dart';
import 'package:health_management/Utils/constants.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  ReminderPageState createState() => ReminderPageState();
}

class ReminderPageState extends State<ReminderPage> {
  List<dynamic> reminders = [];
  int? userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
    if (userId != null) {
      _fetchReminders();
    }
  }

  Future<void> _fetchReminders() async {
    try {
      final response = await http.get(Uri.parse('${Constants.uri}/reminders/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          reminders = data.where((reminder) => reminder['user_id'] == userId).toList();
        });
      } else {
        _showError("Failed to fetch reminders.");
      }
    } catch (e) {
      _showError("Error fetching reminders: $e");
    }
  }

  Future<void> _addReminder(Map<String, dynamic> newReminder) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/reminders'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({...newReminder,"user_id" : userId}),
      );
      if (response.statusCode == 200) {
        _fetchReminders();
        _showError("Reminder added successfully");
      } else {
        _showError("Failed to add reminder.");
      }
    } catch (e) {
      _showError("Error adding reminder: $e");
    }
  }

  void _showError(String message) {
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
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
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
              subtitle: Text("Frequency: ${reminder['Frequency']}\nTime: ${reminder['ReminderTime']}"),
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

          if (newReminder != null ) {
            _addReminder(newReminder);
          }
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
