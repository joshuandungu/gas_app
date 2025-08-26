import 'package:flutter/material.dart';
import 'package:gas/models/gas_model.dart';
import 'package:gas/models/order_model.dart';
import 'package:gas/services/api_service.dart';

/// ✅ Update this to your backend IP
const String BACKEND_BASE = "http://192.168.40.70:5000";

class VendorProvider with ChangeNotifier {
  List<GasModel> _gasListings = [];
  List<OrderModel> _receivedOrders = [];

  List<GasModel> get gasListings => _gasListings;
  List<OrderModel> get receivedOrders => _receivedOrders;

  /// 🔹 Map categories to their backend endpoints
  final Map<String, String> _endpoints = {
    "Gas Product": "/api/gas-products",
    "Bulk Gas Supply": "/api/bulk-gas",
    "Cylinder Exchange": "/api/cylinder-exchange",
    "Cylinder Delivery": "/api/cylinder-delivery",
    "Subscription Plan": "/api/subscriptions",
    "Corporate Supply": "/api/corporate-supply",
  };

  /// 🔹 Fetch ALL gas listings for a vendor
  Future<void> fetchGasListings(String vendorId) async {
    try {
      _gasListings.clear();

      for (final entry in _endpoints.entries) {
        final response =
            await ApiService.get("$BACKEND_BASE${entry.value}?vendorId=$vendorId");

        if (response is List) {
          final listings = response
              .map((json) => GasModel.fromJson({...json, 'category': entry.key}))
              .toList();
          _gasListings.addAll(listings.cast<GasModel>());
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("❌ fetchGasListings error: $e");
      rethrow;
    }
  }

  /// 🔹 Add new gas listing
  Future<void> addGasListing(GasModel gas, String category) async {
    try {
      final endpoint = _endpoints[category] ?? "/api/gas-products";

      final response = await ApiService.post(
        "$BACKEND_BASE$endpoint",
        gas.toJson(),
      );

      final createdGas = GasModel.fromJson({...response, 'category': category});
      _gasListings.add(createdGas);

      notifyListeners();
    } catch (e) {
      debugPrint("❌ addGasListing error: $e");
      rethrow;
    }
  }

  /// 🔹 Update existing gas listing
  Future<void> updateGasListing(GasModel updatedGas, String category) async {
    try {
      final endpoint = _endpoints[category] ?? "/api/gas-products";

      await ApiService.put(
        "$BACKEND_BASE$endpoint/${updatedGas.id}",
        updatedGas.toJson(),
      );

      final index = _gasListings.indexWhere((gas) => gas.id == updatedGas.id);
      if (index != -1) {
        _gasListings[index] = updatedGas;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ updateGasListing error: $e");
      rethrow;
    }
  }

  /// 🔹 Delete gas listing
  Future<void> deleteGasListing(String listingId, String category) async {
    try {
      final endpoint = _endpoints[category] ?? "/api/gas-products";

      await ApiService.delete("$BACKEND_BASE$endpoint/$listingId");

      _gasListings.removeWhere((gas) => gas.id == listingId);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ deleteGasListing error: $e");
      rethrow;
    }
  }

  /// 🔹 Fetch received orders for vendor
  Future<void> fetchReceivedOrders(String vendorId) async {
    try {
      final response =
          await ApiService.get("$BACKEND_BASE/api/vendors/$vendorId/orders");

      _receivedOrders =
          (response as List).map((json) => OrderModel.fromJson(json)).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("❌ fetchReceivedOrders error: $e");
      rethrow;
    }
  }

  /// 🔹 Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await ApiService.put(
        "$BACKEND_BASE/api/orders/$orderId",
        {'status': newStatus},
      );

      final index = _receivedOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _receivedOrders[index] =
            _receivedOrders[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ updateOrderStatus error: $e");
      rethrow;
    }
  }
}
