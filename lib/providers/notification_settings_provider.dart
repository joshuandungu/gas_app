import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newMessages = true;

  NotificationSettingsProvider() {
    _loadSettings();
  }

  bool get orderUpdates => _orderUpdates;
  bool get promotions => _promotions;
  bool get newMessages => _newMessages;

  void setOrderUpdates(bool value) {
    _orderUpdates = value;
    _saveSettings();
    notifyListeners();
  }

  void setPromotions(bool value) {
    _promotions = value;
    _saveSettings();
    notifyListeners();
  }

  void setNewMessages(bool value) {
    _newMessages = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _orderUpdates = prefs.getBool('notification_order_updates') ?? true;
      _promotions = prefs.getBool('notification_promotions') ?? true;
      _newMessages = prefs.getBool('notification_new_messages') ?? true;
    } catch (e) {
      // Log the error or handle it appropriately
      debugPrint('Error loading notification settings: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notification_order_updates', _orderUpdates);
    prefs.setBool('notification_promotions', _promotions);
    prefs.setBool('notification_new_messages', _newMessages);
  }
}