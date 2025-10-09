import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String address;
  final String type;
  final String status;
  final String token;
  final List<dynamic> cart;
  final String shopName;
  final String shopDescription;
  final String shopAvatar;
  final List<String> followers; // Thêm field mới
  final List<String> following; // Thêm field mới
  final double latitude;
  final double longitude;
  final String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.type,
    required this.status,
    required this.token,
    required this.cart,
    this.shopName = '',
    this.shopDescription = '',
    this.shopAvatar = '',
    this.followers = const [],
    this.following = const [],
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.phoneNumber = '',
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'type': type,
      'status': status,
      'token': token,
      'cart': cart,
      'shopName': shopName,
      'shopDescription': shopDescription,
      'shopAvatar': shopAvatar,
      'followers': followers,
      'following': following,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      token: map['token'] ?? '',
      // If map['cart'] is null, use an empty list as a fallback.
      cart: List<Map<String, dynamic>>.from((map['cart'] ?? []).map(
        (x) => Map<String, dynamic>.from(x),
      )),
      shopName: map['shopName'] ?? '',
      shopDescription: map['shopDescription'] ?? '',
      shopAvatar: map['shopAvatar'] ?? '',
      followers: List<String>.from(map['followers'] ?? []), // Convert followers
      following: List<String>.from(map['following'] ?? []), // Convert following
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? address,
    String? type,
    String? status,
    String? token,
    List<dynamic>? cart,
    String? shopName,
    String? shopDescription,
    String? shopAvatar,
    List<String>? followers,
    List<String>? following,
    double? latitude,
    double? longitude,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      address: address ?? this.address,
      type: type ?? this.type,
      status: status ?? this.status,
      token: token ?? this.token,
      cart: cart ?? this.cart,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
      shopAvatar: shopAvatar ?? this.shopAvatar,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  // Helper method để kiểm tra xem user có đang follow một seller không
  bool isFollowing(String sellerId) {
    return following.contains(sellerId);
  }
}
