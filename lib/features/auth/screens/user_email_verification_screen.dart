import 'dart:async';
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
  State<UserEmailVerificationScreen> createState() =>
      _UserEmailVerificationScreenState();
}

class _UserEmailVerificationScreenState
    extends State<UserEmailVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AuthService authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60; // 60 seconds cooldown
    });
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
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
          Navigator.pushNamedAndRemoveUntil(
              context, redirectRoute, (route) => false);
        },
      );
    }
  }

  void resendCode() {
    if (_resendCooldown > 0) return;

    authService.resendVerificationCode(
      context: context,
      email: widget.email,
    );

    _startResendCooldown();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'We\'ve sent a verification code to ${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? "),
                  InkWell(
                    onTap: _resendCooldown > 0 ? null : resendCode,
                    child: Text(
                      _resendCooldown > 0
                          ? 'Resend in $_resendCooldown s'
                          : 'Resend Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _resendCooldown > 0
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                    ),
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
