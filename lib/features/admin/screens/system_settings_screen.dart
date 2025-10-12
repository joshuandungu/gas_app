import 'package:ecommerce_app_fluterr_nodejs/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SystemSettingsScreen extends StatelessWidget {
  static const String routeName = '/system-settings';
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Server Status'),
            subtitle: const Text('Online'),
          ),
          ListTile(
            title: const Text('Database Status'),
            subtitle: const Text('Connected'),
          ),
          ListTile(
            title: const Text('Maintenance Mode'),
            trailing: Switch(
              value: false, // Manage state
              onChanged: (value) {
                // Handle maintenance mode toggle
              },
            ),
          ),
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
