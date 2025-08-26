import 'package:flutter/material.dart';
import 'package:gas/config/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = AppTheme.primaryGreen;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Optional: Method to set primary color if you want to allow dynamic color changes
  void setPrimaryColor(Color color) {
    _primaryColor = color;
    // Note: To dynamically update the theme with a new primary color,
    // you would need to modify AppTheme.lightTheme and AppTheme.darkTheme
    // to use this color, which requires rebuilding the ThemeData objects.
    notifyListeners();
  }
}