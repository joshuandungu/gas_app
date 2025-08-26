
import 'package:flutter/material.dart';
import 'package:gas/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  // Simulate login
  Future<void> login(String email, String password) async {
    // In a real app, you would make an API call to authenticate the user
    // For now, we'll simulate a successful login and create a dummy user
    await Future.delayed(Duration(seconds: 1));

    _user = UserModel(
      id: '1',
      fullName: 'Test User',
      email: email,
      role: 'buyer', // or 'vendor', 'admin' based on the response
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  // Simulate registration
  Future<void> register(String fullName, String email, String password, String role) async {
    // In a real app, you would make an API call to register the user
    await Future.delayed(Duration(seconds: 1));

    _user = UserModel(
      id: '2',
      fullName: fullName,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  // Simulate logout
  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
