class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'buyer', 'vendor', or 'admin'
  final bool isVendor;
  final String? address;
  final String? phoneNumber;
  final String? profileImageUrl; // Profile image URL
  final DateTime createdAt;

  /// ✅ Getter for backward compatibility (so `.name` still works in old code)
  String get name => fullName;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.isVendor = false,
    this.address,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
  });

  /// ✅ Factory constructor to create a UserModel from Firestore/JSON
  factory UserModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError("User data is null");
    }

    return UserModel(
      id: map['id']?.toString() ?? '',
      // fallback ensures compatibility with "name" used in old documents
      fullName: map['fullName']?.toString() ?? map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'buyer', // default role
      isVendor: map['isVendor'] is bool ? map['isVendor'] : false,
      address: map['address']?.toString(),
      // ✅ handle both phoneNumber and legacy phone field
      phoneNumber: map['phoneNumber']?.toString() ?? map['phone']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  /// ✅ Helper to safely parse DateTime from Firestore Timestamp/String
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    try {
      // Firestore Timestamp
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  /// ✅ Convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'isVendor': isVendor,
      'address': address,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
