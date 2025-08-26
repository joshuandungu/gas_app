import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gas/l10n/l10n.dart';
import 'package:gas/providers/locale_provider.dart';
import 'package:gas/screens/auth/login_screen.dart'; // make sure you import your login screen

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final currentLocale = provider.locale;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: L10n.all.length,
        itemBuilder: (context, index) {
          final locale = L10n.all[index];
          final isSelected = locale == currentLocale;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(L10n.getLanguageName(locale.languageCode)),
              onTap: () {
                provider.setLocale(locale);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Language changed to ${L10n.getLanguageName(locale.languageCode)}',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );

                // Delay navigation slightly so the snackbar shows
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }
}
