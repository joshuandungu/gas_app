import 'package:flutter/material.dart';
import 'package:gas/screens/home/main_screen.dart';
import 'package:gas/models/user_model.dart';

// Import your screen files
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password.dart';

import '../screens/admin/admin_home_screen.dart';
import 'package:gas/screens/admin/manage_users.dart';
import 'package:gas/screens/admin/reports_screen.dart';

import '../screens/home/services_Ads/gas_cylinder_delivery_screen.dart';
import '../screens/home/services_Ads/gas_installation_maintenance_screen.dart';
import '../screens/home/services_Ads/gas_safety_checks_screen.dart';
import '../screens/home/services_Ads/emergency_gas_service_screen.dart';

class AppRoute {
  // Route Names for all screens.
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  // Admin Routes
  static const String adminHome = '/admin/home';
  static const String manageUsers = '/admin/manage_users';
  static const String reports = '/admin/reports';

  //other routes can be added here as needed
  static const String loginRoute = '/login';

  // Service Routes
  static const String gasDelivery = '/gas-delivery';
  static const String gasInstallation = '/gas-installation';
  static const String gasSafetyCheck = '/gas-safety-check';
  static const String emergencyGasService = '/emergency-gas-service';

  /// The generateRoute function takes in the [RouteSettings] and returns the
  /// appropriate page route.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Authentication Routes
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
      case home:
        // Pass the required 'user' argument to HomeScreen. Replace 'yourUserObject' with the actual user object.
        return MaterialPageRoute(builder: (_) => MainScreen());

      // Admin Routes
      case adminHome:
        return MaterialPageRoute(builder: (_) => AdminHomeScreen());
      case manageUsers:
        return MaterialPageRoute(builder: (_) => ManageUsersScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => ReportsScreen());

      // Service Routes
      case gasDelivery:
        return MaterialPageRoute(
          builder: (_) => const GasCylinderDeliveryScreen(),
        );
      case gasInstallation:
        return MaterialPageRoute(
          builder: (_) => const GasInstallationMaintenanceScreen(),
        );
      case gasSafetyCheck:
        return MaterialPageRoute(builder: (_) => const GasSafetyChecksScreen());
      case emergencyGasService:
        return MaterialPageRoute(
          builder: (_) => const EmergencyGasServiceScreen(),
        );

      // Unknown route fallback
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('Route Not Found')),
                body: Center(
                  child: Text(
                    'No route defined for ${settings.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
        );
    }
  }
}
