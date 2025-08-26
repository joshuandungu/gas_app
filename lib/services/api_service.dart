
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.40.70:5000/api';

  static Future<List<dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data from $endpoint');
      }
    } catch (e) {
      throw Exception('Error fetching data from $endpoint: $e');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post data to $endpoint');
      }
    } catch (e) {
      throw Exception('Error posting data to $endpoint: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to put data to $endpoint');
      }
    } catch (e) {
      throw Exception('Error putting data to $endpoint: $e');
    }
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to patch data to $endpoint');
      }
    } catch (e) {
      throw Exception('Error patching data to $endpoint: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; // Indicate successful deletion
      } else {
        throw Exception('Failed to delete data from $endpoint');
      }
    } catch (e) {
      throw Exception('Error deleting data from $endpoint: $e');
    }
  }

  // Categories
  static Future<List<dynamic>> getCategories() => get('categories');
  static Future<dynamic> createCategory(Map<String, dynamic> data) => post('categories', data);

  // Products
  static Future<List<dynamic>> getProducts() => get('products');
  static Future<dynamic> createProduct(Map<String, dynamic> data) => post('products', data);

  // Promotions
  static Future<List<dynamic>> getPromotions() => get('promotions');
  static Future<dynamic> createPromotion(Map<String, dynamic> data) => post('promotions', data);

  // Vendors
  static Future<List<dynamic>> getVendors() => get('vendors');
  static Future<dynamic> createVendor(Map<String, dynamic> data) => post('vendors', data);
  
  // Posts
  static Future<List<dynamic>> getPosts() => get('posts');
  static Future<List<dynamic>> getActivePromos() => get('posts/promos');


  // Bulk Gas
  static Future<List<dynamic>> getBulkGas() => get('bulkGas');

  // Corporate Supply
  static Future<List<dynamic>> getCorporateSupply() => get('corporateSupply');

  // Cylinder Delivery
  static Future<List<dynamic>> getCylinderDelivery() => get('cylinderDelivery');

  // Cylinder Exchange
  static Future<List<dynamic>> getCylinderExchange() => get('cylinderExchange');

  // Gas Product
  static Future<List<dynamic>> getGasProduct() => get('gasProduct');

  // Orders
  static Future<List<dynamic>> getOrders() => get('orders');

  // Subscriptions
  static Future<List<dynamic>> getSubscriptions() => get('subscriptions');
}
