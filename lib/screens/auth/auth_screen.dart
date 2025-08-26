
import 'package:flutter/material.dart';
import 'package:gas/screens/auth/login_screen.dart';
import 'package:gas/screens/auth/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;

  void toggleScreen() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginScreen();
    } else {
      return RegisterScreen();
    }
  }
}
