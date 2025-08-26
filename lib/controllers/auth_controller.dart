
import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';
import 'package:gas/services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> login(BuildContext context, String email, String password) async {
    _user = await _authService.login(email, password);
    if (!context.mounted) return;
    if (_user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    notifyListeners();
  }

  Future<void> register(BuildContext context, String fullName, String email, String password) async {
    _user = await _authService.register(fullName, email, password, 'buyer');
    if (!context.mounted) return;
    if (_user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    _user = null;
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/');
    notifyListeners();
  }

  Future<void> forgotPassword(BuildContext context, String email) async {
    await _authService.forgotPassword(email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent.')),
    );
  }
}
