import 'package:flutter/material.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/services/auth_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/auth_screen.dart';

class UserEmailVerificationScreen extends StatefulWidget {
  static const String routeName = '/user-email-verification-screen';
  final String email;
  final String? redirectRoute; // Optional redirect route after verification

  const UserEmailVerificationScreen({
    Key? key,
    required this.email,
    this.redirectRoute,
  }) : super(key: key);

  // Factory constructor to handle arguments from navigation
  factory UserEmailVerificationScreen.fromArguments(Map<String, dynamic> args) {
    return UserEmailVerificationScreen(
      email: args['email'] as String,
      redirectRoute: args['redirectRoute'] as String?,
    );
  }

  @override
  State<UserEmailVerificationScreen> createState() => _UserEmailVerificationScreenState();
}

class _UserEmailVerificationScreenState extends State<UserEmailVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AuthService authService = AuthService();
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void verifyEmail() {
    if (_formKey.currentState!.validate()) {
      authService.verifyEmail(
        context: context,
        email: widget.email,
        code: _codeController.text,
        onSuccess: () {
          // Use the provided redirect route or default to user login screen
          final redirectRoute = widget.redirectRoute ?? AuthScreen.routeName;
          Navigator.pushNamedAndRemoveUntil(context, redirectRoute, (route) => false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter the verification code sent to your email',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.length != 6) {
                    return 'Code must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyEmail,
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
