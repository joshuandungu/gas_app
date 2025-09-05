import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/auth_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_login_screen.dart';
import 'package:flutter/material.dart';

class LoginSelectionScreen extends StatelessWidget {
  static const String routeName = '/login-selection';
  const LoginSelectionScreen({super.key});

  void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/logo_3.png',
                height: 250,
              ),
              const SizedBox(height: 50),
              CustomButton(
                text: 'User Login/Sign Up',
                function: () => navigateTo(context, AuthScreen.routeName),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Seller Login/Sign Up',
                function: () => navigateTo(context, SellerLoginScreen.routeName),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Admin Login',
                function: () => navigateTo(context, AdminLoginScreen.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}