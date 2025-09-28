import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/user_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/widgets/login_form.dart';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: BackButton(color: Colors.black),
        title: const Text('Welcome to Gas App',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Add this to prevent overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 20), // Adjusted top spacing
                // Logo Amazon
                Image.asset(
                  'assets/images/logo_3.png',
                  height: 250,
                ),
                const SizedBox(height: 10), // Increased spacing

                const SizedBox(height: 30), // Increased spacing

                const LoginForm(
                  role: 'user',
                  title: 'Buyer Login ',
                  registerRouteName: UserRegisterScreen.routeName,
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Create a New Account',
                  function: () => Navigator.pushNamed(
                      context, UserRegisterScreen.routeName),
                  color: Colors.grey[200],
                  textColor: Colors.black,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // Use pushNamed to go to the selection screen since the stack was cleared on logout.
                      Navigator.pushNamed(
                          context, LoginSelectionScreen.routeName);
                    },
                    child: const Text('Go back to login selection'),
                  ),
                ),
                const SizedBox(height: 40), // Pushes content up from bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
