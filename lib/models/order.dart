import 'dart:convert';
import 'package:ecommerce_app_fluterr_nodejs/models/product.dart';

class Order {
  final String id;
  final List<Product> products;
  final List<int> quantity;
  final String address;
  final String userId;
  final int orderedAt;
  final int status;
  final bool cancelled;
  final double totalPrice;
  final String phoneNumber;
  final String paymentMethod;
  final String paymentStatus;
  final Map<String, dynamic> paymentDetails;
  Order({
    required this.id,
    required this.products,
    required this.quantity,
    required this.address,
    required this.userId,
    required this.orderedAt,
    required this.status,
    required this.cancelled,
    required this.totalPrice,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentDetails = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'products': products.map((x) => x.toMap()).toList(),
      'quantity': quantity,
      'address': address,
      'userId': userId,
      'orderedAt': orderedAt,
      'status': status,
      'cancelled': cancelled,
      'totalPrice': totalPrice,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentDetails': paymentDetails,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    // Handle products array structure from backend
    List<Product> productsList = [];
    List<int> quantityList = [];

    if (map['products'] != null) {
      for (var item in map['products']) {
        if (item['product'] != null) {
          productsList.add(Product.fromMap(item['product']));
          quantityList.add(item['quantity'] ?? 0);
        }
      }
    }

    return Order(
      id: map['_id'] ?? '',
      products: productsList,
      quantity: quantityList,
      address: map['address'] ?? '',
      userId: map['userId'] ?? '',
      orderedAt: map['orderedAt']?.toInt() ?? 0,
      status: map['status']?.toInt() ?? 0,
      cancelled: map['cancelled'] ?? false,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      phoneNumber: map['phoneNumber'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'COD',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentDetails: Map<String, dynamic>.from(map['paymentDetails'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}