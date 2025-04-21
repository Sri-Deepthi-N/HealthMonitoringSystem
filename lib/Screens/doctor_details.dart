import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/doctor_form.dart';
import 'package:health_management/Screens/home_page.dart';

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({super.key});

  @override
  DoctorDetailsPageState createState() => DoctorDetailsPageState();
}

class DoctorDetailsPageState extends State<DoctorDetailsPage> {
  List<Map<String, dynamic>> doctors = [];
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
      _fetchDoctors();
    }
  }

  Future<void> _fetchDoctors() async {
    if (userId == null) return;
    final dbHelper = DBHelper();
    final data = await dbHelper.getDoctors(userId!);
    setState(() {
      doctors = data;
    });
  }

  Future<void> _addDoctor(Map<String, dynamic> doctor) async {
    if (userId == null) return;
    final dbHelper = DBHelper();
    await dbHelper.insertDoctor({...doctor, 'user_id': userId});
    _showError("Doctor added successfully");
    _fetchDoctors();
  }

  Future<void> _deleteDoctor(int id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteDoctor(id);
    _showError("Doctor deleted successfully");
    _fetchDoctors();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Details"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: doctors.isEmpty
            ? const Center(
          child: Text(
            "No doctor details added yet.",
            style: TextStyle(fontSize: 16),
          ),
        )
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey, width: 1.2),
            headingRowColor: WidgetStateProperty.all(Colors.pink.shade100),
            columns: const [
              DataColumn(label: Text("Doctor Name", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Gender", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Mobile No", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Specialization", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Working Hours", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Hospital Name", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Hospital Address", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: doctors.map((doctor) {
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  return doctors.indexOf(doctor) % 2 == 0 ? Colors.pink.shade50 : null;
                }),
                cells: [
                  DataCell(Text(doctor["DoctorName"] ?? "")),
                  DataCell(Text(doctor["Gender"] ?? "")),
                  DataCell(Text(doctor["PhoneNo"] ?? "")),
                  DataCell(Text(doctor["Specialization"] ?? "")),
                  DataCell(Text(doctor["WorkingHours"] ?? "")),
                  DataCell(Text(doctor["HospitalName"] ?? "")),
                  DataCell(Text(doctor["HospitalAddress"] ?? "")),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDoctor(doctor["id"]),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorFormPage()),
          );
          if (result != null) {
            _addDoctor(result);
          }
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
