import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/home_page.dart';

class FamilyDetailsPage extends StatefulWidget {
  const FamilyDetailsPage({super.key});

  @override
  FamilyDetailsPageState createState() => FamilyDetailsPageState();
}

class FamilyDetailsPageState extends State<FamilyDetailsPage> {
  List<Map<String, dynamic>> familyMembers = [];
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
    _fetchFamilyMembers();
  }

  Future<void> _fetchFamilyMembers() async {
    if (userId == null) return;
    final data = await DBHelper().getFamily(userId!);
    setState(() {
      familyMembers = data;
    });
  }

  Future<void> _addFamilyMember(String name, String mobile, String relation) async {
    if (userId == null) return;
    final newMember = {
      "user_id": userId,
      "Name": name,
      "PhoneNo": mobile,
      "Relation": relation
    };
    await DBHelper().insertFamily(newMember);
    _showError("Family details added successfully");
    _fetchFamilyMembers();
  }

  Future<void> _deleteFamilyMember(int id) async {
    await DBHelper().deleteFamily(id);
    _showError("Family details deleted successfully");
    _fetchFamilyMembers();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddFamilyMemberDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController mobileController = TextEditingController();
    TextEditingController relationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Family Member"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Mobile No"),
              ),
              TextField(
                controller: relationController,
                decoration: const InputDecoration(labelText: "Relation"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    mobileController.text.isNotEmpty &&
                    relationController.text.isNotEmpty) {
                  _addFamilyMember(
                    nameController.text,
                    mobileController.text,
                    relationController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Details"),
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
        child: familyMembers.isEmpty
            ? const Center(child: Text("No family details added yet.", style: TextStyle(fontSize: 16)))
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey, width: 1.2),
            headingRowColor: WidgetStateProperty.all(Colors.pink.shade100),
            columns: const [
              DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Mobile No", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Relation", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: familyMembers.map((member) {
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) => familyMembers.indexOf(member) % 2 == 0 ? Colors.pink.shade50 : null),
                cells: [
                  DataCell(Text(member["Name"] ?? "")),
                  DataCell(Text(member["PhoneNo"] ?? "")),
                  DataCell(Text(member["Relation"] ?? "")),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFamilyMember(member["id"]),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFamilyMemberDialog,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
