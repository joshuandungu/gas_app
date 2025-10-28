import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/user_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/widgets/login_form.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_register_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login-screen';
  final String role;

  const LoginScreen({super.key, required this.role});

  String _getTitle() {
    switch (role) {
      case 'user':
        return 'Buyer Login';
      case 'seller':
        return 'Seller Login';
      case 'admin':
        return 'Admin Login';
      default:
        return 'Login';
    }
  }

  String _getRegisterRouteName() {
    switch (role) {
      case 'user':
        return UserRegisterScreen.routeName;
      case 'seller':
        return SellerRegisterScreen.routeName;
      case 'admin':
        return AdminRegisterScreen.routeName;
      default:
        return UserRegisterScreen.routeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: BackButton(color: Colors.black),
        title: Text(_getTitle(), style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo_3.png',
                  height: 250,
                ),
                const SizedBox(height: 40),
                LoginForm(
                  role: role,
                  title: _getTitle(),
                  registerRouteName: _getRegisterRouteName(),
                  goBackButton: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context,
                          LoginSelectionScreen.routeName, (route) => false);
                    },
                    child: const Text('Go back to role selection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
