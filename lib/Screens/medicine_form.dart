import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/medicine_detail.dart';

class MedicineFormPage extends StatefulWidget {
  const MedicineFormPage({super.key});

  @override
  MedicineFormPageState createState() => MedicineFormPageState();
}

class MedicineFormPageState extends State<MedicineFormPage> {
  final TextEditingController _nameController = TextEditingController();
  bool morning = false;
  bool afternoon = false;
  bool evening = false;
  bool night = false;
  String? foodTiming;
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
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter medicine name")),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please login again.")),
      );
      return;
    }

    final medicineData = {
      'user_id': userId,
      'MedicineName': _nameController.text,
      'Morning': morning ? 1 : 0,
      'Afternoon': afternoon ? 1 : 0,
      'Evening': evening ? 1 : 0,
      'Night': night ? 1 : 0,
      'IntakeTime': foodTiming ?? 'Not Specified',
    };

    await DBHelper().insertMedicine(medicineData);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MedicineDetailsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Medicine"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicineDetailsPage(),
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
            // Medicine Name Input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Intake Time Checkboxes
            const Text("Intake Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CheckboxColumn(label: "Morning", value: morning, onChanged: (v) => setState(() => morning = v)),
                CheckboxColumn(label: "Afternoon", value: afternoon, onChanged: (v) => setState(() => afternoon = v)),
                CheckboxColumn(label: "Evening", value: evening, onChanged: (v) => setState(() => evening = v)),
                CheckboxColumn(label: "Night", value: night, onChanged: (v) => setState(() => night = v)),
              ],
            ),
            const SizedBox(height: 20),

            // Before Food / After Food
            const Text("Food Timing", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RadioRow(label: "Before Food", value: "Before Food", groupValue: foodTiming, onChanged: (v) => setState(() => foodTiming = v)),
                RadioRow(label: "After Food", value: "After Food", groupValue: foodTiming, onChanged: (v) => setState(() => foodTiming = v)),
              ],
            ),
            const SizedBox(height: 20),

            // Submit & Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                  child: const Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CheckboxColumn extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const CheckboxColumn({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
        ),
        Text(label),
      ],
    );
  }
}

class RadioRow extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final Function(String?) onChanged;

  const RadioRow({super.key, required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}
