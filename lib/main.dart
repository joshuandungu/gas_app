import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'controllers/home_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/buyer_controller.dart';
import 'config/app_theme.dart';
import 'l10n/l10n.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/theme_provider.dart'; 
import 'providers/vendor_provider.dart'; // ✅ Import VendorProvider
import 'config/app_routes.dart';
import 'package:gas/providers/cart_provider.dart'; // ✅ Import CartProvider
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    if (!kIsWeb &&
        (Platform.isAndroid ||
            Platform.isIOS ||
            Platform.isMacOS ||
            Platform.isWindows)) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      debugPrint("⚠️ Skipping Firebase initialization for this platform");
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => BuyerController()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()), // ✅ Added VendorProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Larry Enterprises',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRoute.generateRoute,
      initialRoute: AppRoute.splash,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      ),
    );
  }
}
