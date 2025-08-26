
import 'package:flutter/material.dart';
import 'package:gas/models/gas_model.dart';
import 'package:gas/models/order_model.dart';

class BuyerProvider with ChangeNotifier {
  List<GasModel> _availableGases = [];
  final List<OrderItem> _cart = [];
  final List<OrderModel> _orders = [];

  List<GasModel> get availableGases => _availableGases;
  List<OrderItem> get cart => _cart;
  List<OrderModel> get orders => _orders;

  // Fetch available gases
  Future<void> fetchGases() async {
    // In a real app, you would fetch this from your API
    await Future.delayed(Duration(seconds: 1));
    _availableGases = [
      GasModel(id: 'g1', name: 'LPG 12kg', description: 'Standard 12kg LPG cylinder', price: 25.0, vendorId: 'v1', quantityAvailable: 50, imageUrl: '', lastUpdated: DateTime.now()),
      GasModel(id: 'g2', name: 'LPG 5kg', description: 'Smaller 5kg LPG cylinder', price: 12.0, vendorId: 'v2', quantityAvailable: 100, imageUrl: '', lastUpdated: DateTime.now()),
    ];
    notifyListeners();
  }

  // Add to cart
  void addToCart(GasModel gas, int quantity) {
    final existingIndex = _cart.indexWhere((item) => item.gasId == gas.id);
    if (existingIndex != -1) {
      _cart[existingIndex] = OrderItem(
        gasId: gas.id,
        name: gas.name,
        quantity: _cart[existingIndex].quantity + quantity,
        priceAtPurchase: gas.price,
      );
    } else {
      _cart.add(OrderItem(
        gasId: gas.id,
        name: gas.name,
        quantity: quantity,
        priceAtPurchase: gas.price,
      ));
    }
    notifyListeners();
  }

  // Remove from cart
  void removeFromCart(String gasId) {
    _cart.removeWhere((item) => item.gasId == gasId);
    notifyListeners();
  }

  // Place order
  Future<void> placeOrder(String buyerId, String vendorId, String deliveryAddress) async {
    // In a real app, you would send this to your API
    await Future.delayed(Duration(seconds: 1));
    final newOrder = OrderModel(
      id: DateTime.now().toString(),
      buyerId: buyerId,
      vendorId: vendorId,
      items: List.from(_cart),
      totalPrice: _cart.fold(0, (sum, item) => sum + (item.priceAtPurchase * item.quantity)),
      status: 'pending',
      deliveryAddress: deliveryAddress,
      orderDate: DateTime.now(),
    );
    _orders.add(newOrder);
    _cart.clear();
    notifyListeners();
  }
}
