import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gas/providers/theme_provider.dart';

class ThemeAppearanceScreen extends StatelessWidget {
  const ThemeAppearanceScreen({super.key});

  static final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.themeMode;
    final currentColor = themeProvider.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Appearance'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                isSelected: [
                  currentTheme == ThemeMode.light,
                  currentTheme == ThemeMode.dark,
                  currentTheme == ThemeMode.system,
                ],
                onPressed: (index) {
                  ThemeMode selectedMode;
                  if (index == 0) {
                    selectedMode = ThemeMode.light;
                  } else if (index == 1) {
                    selectedMode = ThemeMode.dark;
                  } else {
                    selectedMode = ThemeMode.system;
                  }
                  themeProvider.setThemeMode(selectedMode);
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Light'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Dark'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('System'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Primary Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.map((color) {
                final isSelected = color == currentColor;
                return GestureDetector(
                  onTap: () => themeProvider.setPrimaryColor(color),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: isSelected ? 24 : 20,
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Current Theme: ${_themeModeToString(currentTheme)}',
                style: TextStyle(
                  fontSize: 16,
                  color: currentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}