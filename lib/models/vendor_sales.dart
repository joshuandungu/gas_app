import 'dart:convert';

class VendorSales {
  final String sellerId;
  final double totalRevenue;
  final int completedOrders;
  final String shopName;
  final String shopAvatar;

  VendorSales({
    required this.sellerId,
    required this.totalRevenue,
    required this.completedOrders,
    required this.shopName,
    required this.shopAvatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'totalRevenue': totalRevenue,
      'completedOrders': completedOrders,
      'shopName': shopName,
      'shopAvatar': shopAvatar,
    };
  }

  factory VendorSales.fromMap(Map<String, dynamic> map) {
    return VendorSales(
      sellerId: map['sellerId'] ?? '',
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      completedOrders: map['completedOrders']?.toInt() ?? 0,
      shopName: map['shopName'] ?? 'Unknown Shop',
      shopAvatar: map['shopAvatar'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory VendorSales.fromJson(String source) =>
      VendorSales.fromMap(json.decode(source));
}
