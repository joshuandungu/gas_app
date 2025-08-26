import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      return sum + (item['price'] as num) * (item['quantity'] as num);
    });
  }

  void addItem(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item['id'] == product['id']);
    if (index >= 0) {
      _items[index]['quantity'] += 1;
    } else {
      _items.add({...product, 'quantity': 1});
    }
    notifyListeners();
  }

  void removeItem(dynamic id) {
    _items.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void updateQuantity(dynamic id, int newQuantity) {
    final index = _items.indexWhere((item) => item['id'] == id);
    if (index >= 0 && newQuantity > 0) {
      _items[index]['quantity'] = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
