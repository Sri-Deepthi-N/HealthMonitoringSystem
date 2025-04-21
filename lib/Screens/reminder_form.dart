import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_management/Notification/notification_services.dart';

class ReminderFormPage extends StatefulWidget {
  const ReminderFormPage({super.key});

  @override
  ReminderFormPageState createState() => ReminderFormPageState();
}

class ReminderFormPageState extends State<ReminderFormPage> {
  final TextEditingController _activityController = TextEditingController();
  String _selectedFrequency = 'Daily';
  String _selectedReminder = 'Needed';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveReminder(){
    if (_activityController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    String formattedTime = _selectedTime!.format(context);

    DateTime scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final reminderData = {
      "Activity": _activityController.text,
      "Frequency": _selectedFrequency,
      "ReminderNeeded": _selectedReminder,
      "ReminderDate": formattedDate,
      "ReminderTime": formattedTime,
    };

    if (_selectedReminder == "Needed") {
      NotificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Reminder',
        body: _activityController.text,
        scheduledTime: scheduledDateTime,
        repeatFrequency: _selectedFrequency,
      );
    }
    Navigator.pop(context, reminderData);
  }

  Widget _buildRadioOption(String value) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(value),
        value: value,
        groupValue: _selectedFrequency,
        onChanged: (String? newValue) {
          setState(() {
            _selectedFrequency = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildReminderOption(String value) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(value),
        value: value,
        groupValue: _selectedReminder,
        onChanged: (String? newValue) {
          setState(() {
            _selectedReminder = newValue!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Reminder Form"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Activity:"),
            TextField(
              controller: _activityController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const Text("Frequency:"),
            Row(
              children: [
                _buildRadioOption("Daily"),
                _buildRadioOption("Weekly"),
              ],
            ),
            Row(
              children: [
                _buildRadioOption("Monthly"),
                _buildRadioOption("Yearly"),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Reminders:"),
            Row(
              children: [
                _buildReminderOption("Needed"),
                _buildReminderOption("Not Needed"),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Last Completed On:"),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDate(context),
                    child: Text(
                      _selectedDate == null
                          ? "Pick Date"
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickTime(context),
                    child: Text(
                      _selectedTime == null
                          ? "Pick Time"
                          : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
