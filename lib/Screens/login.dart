import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:health_management/Authentication/backend.dart';
import 'package:health_management/Screens/home_page.dart';
import 'package:health_management/Screens/signup.dart';
import 'package:health_management/Screens/watch_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isConnected = false;
  late Stream<ConnectionStateUpdate> _connectionStream;
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  void _login() async {
    String mobile = _mobileController.text.trim();
    String password = _passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      _showMessage("Please enter mobile and password");
      return;
    }

    final user = await DBHelper().getUserByMobile(mobile);
    if (user != null && user['Password'] == password) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user['id']);
      await prefs.setString('UserName', user['UserName']);
      await prefs.setString('PhoneNo', user['PhoneNo']);
      isConnected == true ? Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      ) :
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BluetoothScreen()),
      );
    } else {
      _showMessage("No user found");
    }
  }

  Future<void> _checkConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id');
    if (deviceId != null) {
      _connectionStream = _ble.connectToDevice(id: deviceId);
      _connectionStream.listen((update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          setState(() => isConnected = true);
        } else {
          setState(() => isConnected = false);
        }
      }, onError: (e) {
        setState(() => isConnected = false);
      });
    } else {
      setState(() => isConnected = false);
    }
  }
  void _cancel() {
    _mobileController.clear();
    _passwordController.clear();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkConnection();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.jpg', height: 100),
              const SizedBox(height: 20),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Mobile Number", Icons.person),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration("Password", Icons.lock),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    style: _buttonStyle(Colors.pinkAccent),
                    child: const Text("Login"),
                  ),
                  ElevatedButton(
                    onPressed: _cancel,
                    style: _buttonStyle(Colors.grey),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {},
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.pink)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text("Sign Up", style: TextStyle(color: Colors.pink)),
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
