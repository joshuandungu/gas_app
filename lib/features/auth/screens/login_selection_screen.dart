import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class LoginSelectionScreen extends StatelessWidget {
  static const String routeName = '/login-selection';
  const LoginSelectionScreen({super.key});

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
                text: 'Become a Buyer',
                function: () => Navigator.pushNamed(
                    context, LoginScreen.routeName,
                    arguments: 'user'),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Become a Seller',
                function: () => Navigator.pushNamed(
                    context, LoginScreen.routeName,
                    arguments: 'seller'),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Admin Login',
                function: () => Navigator.pushNamed(
                    context, LoginScreen.routeName,
                    arguments: 'admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
