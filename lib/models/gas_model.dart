class GasModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String vendorId;
  final double quantityAvailable;
  final String imageUrl;
  final DateTime lastUpdated;
  final String category; // 🔹 NEW: helps know which API it came from

  GasModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.vendorId,
    required this.quantityAvailable,
    required this.imageUrl,
    required this.lastUpdated,
    this.category = "", // default empty
  });

  /// ✅ Factory constructor to create a GasModel from JSON/Map
  factory GasModel.fromJson(Map<String, dynamic> json, {String category = ""}) {
    return GasModel(
      id: json['id']?.toString() ?? "",
      name: json['name']?.toString() ?? "Unnamed",
      description: json['description']?.toString() ?? "",
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? "0") ?? 0,
      vendorId: json['vendorId']?.toString() ?? "",
      quantityAvailable: (json['quantityAvailable'] is num)
          ? (json['quantityAvailable'] as num).toDouble()
          : double.tryParse(json['quantityAvailable']?.toString() ?? "0") ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? "",
      lastUpdated: _parseDate(json['lastUpdated']),
      category: category,
    );
  }

  /// ✅ Convert a GasModel instance to JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'vendorId': vendorId,
      'quantityAvailable': quantityAvailable,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
      'category': category,
    };
  }

  /// ✅ CopyWith method for immutability
  GasModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? vendorId,
    double? quantityAvailable,
    String? imageUrl,
    DateTime? lastUpdated,
    String? category,
  }) {
    return GasModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      vendorId: vendorId ?? this.vendorId,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
    );
  }

  /// ✅ Helper to parse `lastUpdated` safely
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    try {
      // Firestore Timestamp support
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }
}
