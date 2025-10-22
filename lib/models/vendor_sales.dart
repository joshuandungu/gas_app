import 'dart:convert';

class VendorSales {
  final String id;
  final double totalRevenue;
  final int completedOrders;
  final String shopName;
  final String shopAvatar;

  VendorSales({
    required this.id,
    required this.totalRevenue,
    required this.completedOrders,
    required this.shopName,
    required this.shopAvatar,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'totalRevenue': totalRevenue,
      'completedOrders': completedOrders,
      'shopName': shopName,
      'shopAvatar': shopAvatar,
    };
  }

  factory VendorSales.fromMap(Map<String, dynamic> map) {
    return VendorSales(
      id: map['_id'] ?? '',
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      completedOrders: map['completedOrders']?.toInt() ?? 0,
      shopName: map['sellerInfo']?['shopName'] ?? 'Unknown Shop',
      shopAvatar: map['sellerInfo']?['shopAvatar'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory VendorSales.fromJson(String source) =>
      VendorSales.fromMap(json.decode(source));
}
