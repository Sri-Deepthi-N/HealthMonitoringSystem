import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_management/Authentication/auth_services.dart';
import 'package:health_management/Screens/login.dart';
import 'package:health_management/Screens/signup.dart';
import 'package:health_management/Notification/notification_services.dart';
import 'package:health_management/Provider/user_provider.dart';
import 'package:health_management/Screens/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await authService.getUserData(context);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Provider.of<UserProvider>(context).user.JWTToken.isEmpty ? const LoginPage() : HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}