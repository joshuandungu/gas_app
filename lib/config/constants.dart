
import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primaryColor = Color(0xFF0D47A1); // Deep Blue
  static const Color secondaryColor = Color(0xFF1976D2); // Bright Blue
  static const Color accentColor = Color(0xFFFFC107); // Amber
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color textColor = Color(0xFF333333); // Dark Grey
  static const Color whiteColor = Colors.white;
}

// Strings
class AppStrings {
  static const String appName = 'Larry Enterprices';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Full Name';
  static const String role = 'Role';
  static const String buyer = 'Buyer';
  static const String vendor = 'Vendor';
  static const String admin = 'Admin';
}

// API Endpoints
class ApiEndpoints {
  static const String baseUrl = 'https://your-api-url.com/api';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  // Add other endpoints here
}

// Dimensions
class AppDimensions {
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
}
