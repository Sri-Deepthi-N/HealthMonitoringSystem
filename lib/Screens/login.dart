import 'package:flutter/material.dart';
import 'package:health_management/Authentication/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService authService = AuthService();

  void _login() {
    String mobile = _mobileController.text.trim();
    String password = _passwordController.text.trim();
    authService.signInUser(context: context, mobile: mobile, password: password);
  }

  void _cancel() {
    _mobileController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/logo.jpg', // Ensure the logo image is in assets folder
                height: 100,
              ),
              const SizedBox(height: 20),

              // Username Field
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login & Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text("Login"),
                  ),
                  ElevatedButton(
                    onPressed: _cancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Forgot Password Link
              TextButton(
                onPressed: () {
                  // Add forgot password functionality
                },
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.blue)),
              ),

              // Sign-up Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context,"/signup");
                    },
                    child: const Text("Sign Up", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}