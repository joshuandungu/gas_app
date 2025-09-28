import 'dart:async';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class AdminEmailVerificationScreen extends StatefulWidget {
  static const String routeName = '/admin-email-verification-screen';
  final String email;

  const AdminEmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<AdminEmailVerificationScreen> createState() =>
      _AdminEmailVerificationScreenState();
}

class _AdminEmailVerificationScreenState
    extends State<AdminEmailVerificationScreen> {
  final AuthService authService = AuthService();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60; // 60 seconds cooldown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void verifyCode() {
    if (_codeController.text.trim().isEmpty) {
      showSnackBar(context, "Please enter the verification code");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    authService.verifyEmail(
      context: context,
      email: widget.email,
      code: _codeController.text.trim(),
      onSuccess: () {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, "Email verified successfully!");
        // Navigate to admin login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin-login-screen',
          (route) => false,
        );
      },
    );
  }

  void resendCode() {
    if (_resendCooldown > 0) {
      showSnackBar(context, "Please wait $_resendCooldown seconds before resending");
      return;
    }

    // For now, we'll just show a message since resend functionality
    // might need to be implemented on the server side
    showSnackBar(context, "Please check your email for the verification code");
    _startResendCooldown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Admin Email'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We have sent a 6-digit verification code to:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please enter the 6-digit code below:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Verify Email',
                      function: verifyCode,
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Wrong email? "),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
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
