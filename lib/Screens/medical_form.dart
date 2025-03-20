import 'package:flutter/material.dart';
import 'package:health_management/Screens/medical_details.dart';

class HealthDetailsFormPage extends StatefulWidget {
  const HealthDetailsFormPage({super.key});

  @override
  HealthDetailsFormPageState createState() => HealthDetailsFormPageState();
}

class HealthDetailsFormPageState extends State<HealthDetailsFormPage> {
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  List<String> selectedTreatments = [];
  List<String> selectedTablets = [];

  final List<String> treatmentOptions = [
    "Surgery",
    "Chemotherapy",
    "Physiotherapy",
    "Dialysis",
    "Other"
  ];
  final List<String> tabletOptions = [
    "Painkillers",
    "Antibiotics",
    "Insulin",
    "Vitamin Supplements",
    "Other"
  ];

  Future<void> _saveHealthDetails() async {
    if (_conditionController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    Map<String, dynamic> healthData = {
      "Condition": _conditionController.text,
      "Height": int.parse(_heightController.text),
      "Weight": int.parse(_weightController.text),
      "Age": int.parse(_ageController.text),
      "Treatment": selectedTreatments.join(","), // Convert list to string
      "Tablet": selectedTablets.join(","), // Convert list to string
    };
    Navigator.pop(context,healthData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Details Form'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MedicalHistoryPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Medical Condition", _conditionController),
            _buildTextField("Height (cm)", _heightController, isNumeric: true),
            _buildTextField("Weight (kg)", _weightController, isNumeric: true),
            _buildTextField("Age", _ageController, isNumeric: true),
            _buildMultiSelectDropdown(
                'Undergone Treatment For', selectedTreatments, treatmentOptions),
            _buildMultiSelectDropdown(
                'Consume Tablets For', selectedTablets, tabletOptions),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MedicalHistoryPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveHealthDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildMultiSelectDropdown(String title, List<String> selectedItems, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: selectedItems.map((item) {
                    return Chip(
                      label: Text(item),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedItems.remove(item);
                        });
                      },
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Select options"),
                  items: options.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && !selectedItems.contains(value)) {
                      setState(() {
                        selectedItems.add(value);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
