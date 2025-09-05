import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_textfield.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/services/auth_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/widgets/reset_password_dialog.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final String role;
  final String registerRouteName;
  final String title;
  final String signUpText;
  final Widget? goBackButton;

  const LoginForm({
    super.key,
    required this.role,
    required this.registerRouteName,
    required this.title,
    this.signUpText = "Don't have an account? ",
    this.goBackButton,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _signInFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signIn() {
    if (_signInFormKey.currentState!.validate()) {
      authService.signInUser(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
        role: widget.role,
      );
    }
  }

  void showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ResetPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          CustomTextField(
            textController: _emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            textController: _passwordController,
            hintText: 'Password',
            keyboardType: TextInputType.text,
            isPass: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: showResetPasswordDialog,
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: 'Sign In',
            function: signIn,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.signUpText),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, widget.registerRouteName);
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (widget.goBackButton != null) ...[
            const SizedBox(height: 10),
            widget.goBackButton!,
          ]
        ],
      ),
    );
  }
}
