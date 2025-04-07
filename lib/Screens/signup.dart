import 'package:flutter/material.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _signup() async {
    String username = _usernameController.text.trim();
    String mobile = _mobileController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || mobile.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }
    final existingUser = await DBHelper().getUserByMobile(mobile);
    if (existingUser != null) {
      _showMessage("Mobile number already registered");
      return;
    }
    try{
      await DBHelper().signup({
        "UserName": username,
        "PhoneNo": mobile,
        "Password": password,
      });
      _showMessage("Sign up successful");
    }catch(e){
      _showMessage(e.toString());
    }

    _usernameController.clear();
    _mobileController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _cancel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.jpg',
                height: 100,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: _inputDecoration("UserName", Icons.person),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Mobile Number", Icons.phone),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration("Password", Icons.lock),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration("Confirm Password", Icons.lock_outline),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _signup,
                    style: _buttonStyle(Colors.pinkAccent),
                    child: const Text("Sign Up"),
                  ),
                  ElevatedButton(
                    onPressed: _cancel,
                    style: _buttonStyle(Colors.grey),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text("Login", style: TextStyle(color: Colors.pink)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    );
  }
}
