import 'package:flutter/material.dart';

class BuyerController with ChangeNotifier {
  // Example properties
  List<GasDelivery> _deliveries = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<GasDelivery> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Business logic methods
  Future<void> loadDeliveries() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call or replace with actual implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // Replace with your actual data fetching logic
      _deliveries = [
        GasDelivery(id: '1', address: '123 Main St', status: 'Pending'),
        GasDelivery(id: '2', address: '456 Oak Ave', status: 'Delivered'),
      ];

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load deliveries: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDeliveryStatus(String id, String newStatus) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call or replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _deliveries.indexWhere((d) => d.id == id);
      if (index != -1) {
        _deliveries[index] = _deliveries[index].copyWith(status: newStatus);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update delivery: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// Model class for gas deliveries
class GasDelivery {
  final String id;
  final String address;
  final String status;

  GasDelivery({
    required this.id,
    required this.address,
    required this.status,
  });

  GasDelivery copyWith({
    String? id,
    String? address,
    String? status,
  }) {
    return GasDelivery(
      id: id ?? this.id,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }
}