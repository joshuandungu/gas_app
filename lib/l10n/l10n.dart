import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('sw'),
    const Locale('fr'),
    const Locale('de'),
    const Locale('zh'),
    const Locale('la'),
    const Locale('es'),
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'sw': return 'Swahili';
      case 'fr': return 'French';
      case 'de': return 'German';
      case 'zh': return 'Chinese';
      case 'la': return 'Latin';
      case 'es': return 'Spanish';
      default: return code;
    }
  }
}