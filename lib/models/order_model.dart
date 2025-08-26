
class OrderModel {
  final String id;
  final String buyerId;
  final String vendorId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status; // e.g., 'pending', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'
  final String deliveryAddress;
  final DateTime orderDate;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.deliveryAddress,
    required this.orderDate,
  });

  // Factory constructor to create an OrderModel from a map (e.g., from JSON)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      vendorId: json['vendorId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
    );
  }

  // Method to convert an OrderModel instance to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'vendorId': vendorId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? vendorId,
    List<OrderItem>? items,
    double? totalPrice,
    String? status,
    String? deliveryAddress,
    DateTime? orderDate,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      vendorId: vendorId ?? this.vendorId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderDate: orderDate ?? this.orderDate,
    );
  }
}

class OrderItem {
  final String gasId;
  final String name;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.gasId,
    required this.name,
    required this.quantity,
    required this.priceAtPurchase,
  });

  // Factory constructor to create an OrderItem from a map
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      gasId: json['gasId'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
    );
  }

  // Method to convert an OrderItem instance to a map
  Map<String, dynamic> toJson() {
    return {
      'gasId': gasId,
      'name': name,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
    };
  }
}
