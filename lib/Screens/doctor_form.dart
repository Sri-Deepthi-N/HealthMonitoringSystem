import 'package:flutter/material.dart';

class DoctorFormPage extends StatefulWidget {
  const DoctorFormPage({super.key});

  @override
  DoctorFormPageState createState() => DoctorFormPageState();
}

class DoctorFormPageState extends State<DoctorFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController hospitalAddressController = TextEditingController();

  String gender = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (gender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select gender")),
        );
        return;
      }

      Map<String, dynamic> doctor = {
        "DoctorName": nameController.text,
        "Gender": gender,
        "PhoneNo": mobileController.text,
        "Specialization": specializationController.text,
        "WorkingHours": workingHoursController.text,
        "HospitalName": hospitalNameController.text,
        "HospitalAddress": hospitalAddressController.text,
      };

      Navigator.pop(context, doctor);
    }
  }


  void _cancelForm() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Doctor"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Doctor Name"),
                    validator: (value) =>
                    value!.isEmpty ? "Please enter Doctor Name" : null,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Gender: "),
                        Radio<String>(
                          value: "Male",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                        ),
                        const Text("Male"),
                        Radio<String>(
                          value: "Female",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                        ),
                        const Text("Female"),
                      ],
                    ),
                  ),

                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Mobile No"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter Mobile No";
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return "Enter a valid 10-digit Mobile No";
                      }
                      return null;
                    },
                  ),

                  TextFormField(
                    controller: specializationController,
                    decoration: const InputDecoration(labelText: "Specialization"),
                    validator: (value) =>
                    value!.isEmpty ? "Please enter Specialization" : null,
                  ),

                  TextFormField(
                    controller: workingHoursController,
                    decoration: const InputDecoration(labelText: "Working Hours"),
                    validator: (value) =>
                    value!.isEmpty ? "Please enter Working Hours" : null,
                  ),

                  TextFormField(
                    controller: hospitalNameController,
                    decoration: const InputDecoration(labelText: "Hospital Name"),
                    validator: (value) =>
                    value!.isEmpty ? "Please enter Hospital Name" : null,
                  ),

                  TextFormField(
                    controller: hospitalAddressController,
                    decoration: const InputDecoration(labelText: "Hospital Address"),
                    validator: (value) =>
                    value!.isEmpty ? "Please enter Hospital Address" : null,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _cancelForm,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
