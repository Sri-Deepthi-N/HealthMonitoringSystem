import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Screens/medical_details.dart';
import 'package:health_management/Authentication/backend.dart'; // For DBHelper

class HealthDetailsFormPage extends StatefulWidget {
  const HealthDetailsFormPage({super.key});

  @override
  HealthDetailsFormPageState createState() => HealthDetailsFormPageState();
}

class HealthDetailsFormPageState extends State<HealthDetailsFormPage> {
  final TextEditingController _conditionController = TextEditingController();
  List<String> selectedTreatments = [];
  List<String> selectedTablets = [];
  List<String> existingMedicines = [];
  String? selectedMedicine;
  int? userId;

  final List<String> treatmentOptions = [
    "Surgery",
    "Chemotherapy",
    "Physiotherapy",
    "Dialysis",
    "Other"
  ];

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
      _loadExistingMedicines();
    }
  }

  Future<void> _loadExistingMedicines() async {
    final meds = await DBHelper().getMedicines(userId!);
    setState(() {
      existingMedicines =
          meds.map<String>((e) => e['MedicineName'] as String).toSet().toList();
    });
  }

  Future<void> _saveHealthDetails() async {
    if (_conditionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }
    Map<String, dynamic> healthData = {
      "Condition": _conditionController.text,
      "Treatment": selectedTreatments.join(","),
      "Tablet": selectedTablets.join(","),
    };
    Navigator.pop(context, healthData);
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Medical Condition", _conditionController),
              _buildMultiSelectDropdown(
                'Undergone Treatment For',
                selectedTreatments,
                treatmentOptions,
              ),
              _buildTabletInputSection(),
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
      ),
    );
  }

  Widget _buildTabletInputSection() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Consume Tablets For", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Show added tablets as Chips
        Wrap(
          spacing: 8,
          children: selectedTablets.map((tablet) {
            return Chip(
              label: Text(tablet),
              onDeleted: () {
                setState(() {
                  selectedTablets.remove(tablet);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // Dropdown for existing medicines
        DropdownButtonFormField<String>(
          value: selectedMedicine,
          decoration: const InputDecoration(
            labelText: "Select from existing medicines",
            border: OutlineInputBorder(),
          ),
          items: existingMedicines.map((medicine) {
            return DropdownMenuItem<String>(
              value: medicine,
              child: Text(medicine),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && !selectedTablets.contains(value)) {
              setState(() {
                selectedTablets.add(value);
                selectedMedicine = null;
              });
            }
          },
        ),
        const SizedBox(height: 10),
      ],
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
          border: const OutlineInputBorder(),
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
                  value: null,
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
