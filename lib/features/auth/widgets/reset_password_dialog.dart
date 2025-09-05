import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_textfield.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

enum ResetStep { enterEmail, enterPassword }

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  ResetStep _currentStep = ResetStep.enterEmail;
  String? _resetToken;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_emailController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    String? token = await authService.resetPassword(
      context: context,
      email: _emailController.text,
    );

    if (token != null) {
      setState(() {
        _resetToken = token;
        _currentStep = ResetStep.enterPassword;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.isEmpty || _resetToken == null) return;

    setState(() {
      _isLoading = true;
    });

    bool success = await authService.updatePassword(
      context: context,
      resetToken: _resetToken!,
      newPassword: _newPasswordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pop(); // Pop the dialog
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    switch (_currentStep) {
      case ResetStep.enterEmail:
        return CustomTextField(
          textController: _emailController,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
        );
      case ResetStep.enterPassword:
        return CustomTextField(
          textController: _newPasswordController,
          hintText: 'Enter new password',
          isPass: true,
          keyboardType: TextInputType.text,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_currentStep == ResetStep.enterEmail
          ? 'Reset Password'
          : 'Enter New Password'),
      content: _buildContent(),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _currentStep == ResetStep.enterEmail
                    ? _sendResetLink
                    : _updatePassword,
                child: Text(_currentStep == ResetStep.enterEmail
                    ? 'Send Reset Link'
                    : 'Update Password'),
              ),
            ],
    );
  }
}
