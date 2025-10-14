import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/models/sales.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/models/shop_stats.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/product.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SellerServices {
  Future<String> registerSeller({
    required BuildContext context,
    required String shopName,
    required String shopDescription,
    required String address,
    required Uint8List avatar,
    bool popOnSuccess = false,
    required String userId,
    required double latitude,
    required double longitude,
    String? phone,
  }) async {
    String status = '';
    try {
      // Upload avatar to cloudinary
      final cloudinary = CloudinaryPublic('dvgeq2l6e', 'xuvwiao4');
      CloudinaryResponse avatarRes;

      avatarRes = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          avatar, // Uint8List data
          identifier: 'shop_avatar_${DateTime.now().millisecondsSinceEpoch}',
          folder: shopName,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/register-seller'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'shopName': shopName,
          'shopDescription': shopDescription,
          'userId': userId,
          'address': address,
          'avatarUrl': avatarRes.secureUrl,
          'latitude': latitude,
          'longitude': longitude,
          'phone': phone,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          status = jsonDecode(res.body)['status'];
          showSnackBar(
            context,
            'Seller registration request sent successfully!',
          );
          if (popOnSuccess) {
            Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return status;
  }

  Future<void> requestSellerStatus({
    required BuildContext context,
    required String shopName,
    required String shopDescription,
    required String address,
    required Uint8List avatar,
    required String userId,
    required double latitude,
    required double longitude,
    required String phone,
  }) async {
    try {
      // Upload avatar to cloudinary
      final cloudinary = CloudinaryPublic('dvgeq2l6e', 'xuvwiao4');
      CloudinaryResponse avatarRes;

      avatarRes = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          avatar, // Uint8List data
          identifier: 'shop_avatar_${DateTime.now().millisecondsSinceEpoch}',
          folder: shopName,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      http.Response res = await http.post(
        Uri.parse('$uri/api/register-seller-auth'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'shopName': shopName,
          'shopDescription': shopDescription,
          'address': address,
          'avatarUrl': avatarRes.secureUrl,
          'latitude': latitude,
          'longitude': longitude,
          'phone': phone,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Seller request submitted successfully! You are now a seller.',
          );
          // Update user type in provider
          userProvider.setUserFromModel(
            userProvider.user.copyWith(type: 'seller'),
          );
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<String> checkRequestStatus(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String status = '';
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/seller-request-status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          status = jsonDecode(res.body)['status'];
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return status;
  }

  Future<bool> sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required List<Uint8List> images,
    required String sellerId,
  }) async {
    bool isSuccess = false;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      debugPrint('Starting product upload process...');
      debugPrint('Images to upload: ${images.length}');
      // ko luu anh tren mongodb vi dung luong kha it(shared clutter),luu anh tren cloudinary
      final cloudinary = CloudinaryPublic('dvgeq2l6e', 'xuvwiao4');
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res;
        try {
          debugPrint('Uploading image $i to Cloudinary...');
          // Sanitize folder name to avoid issues with special characters
          String sanitizedFolder = name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
          res = await cloudinary.uploadFile(
            CloudinaryFile.fromBytesData(
              images[i], // Uint8List data
              identifier:
                  'product_image_${DateTime.now().millisecondsSinceEpoch}_$i',
              folder: sanitizedFolder,
              resourceType: CloudinaryResourceType.Image,
            ),
          );
          debugPrint('Image $i uploaded successfully: ${res.secureUrl}');
          imageUrls.add(res.secureUrl);
        } catch (e) {
          debugPrint('Failed to upload image $i: $e');
          // Add more detailed error logging
          if (e is DioException && e.response != null) {
            debugPrint('Response status: ${e.response?.statusCode}');
            debugPrint('Response data: ${e.response?.data}');
          }
          showSnackBar(context, 'Failed to upload image $i: $e');
          return false;
        }
      }
      debugPrint('All images uploaded. Creating product...');
      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        images: imageUrls,
        category: category,
        price: price,
        sellerId: sellerId,
      );
      debugPrint('Sending product to server...');
      http.Response res = await http.post(
        Uri.parse('$uri/seller/add-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );
      debugPrint('Server response status: ${res.statusCode}');
      debugPrint('Server response body: ${res.body}');
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          isSuccess = true;
          debugPrint('Product added successfully');
        },
      );
    } catch (e) {
      debugPrint('Error in sellProduct: $e');
      showSnackBar(context, e.toString());
    }
    return isSuccess;
  }

  // get all the products
  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/get-products'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final List<dynamic> productData = jsonDecode(res.body);
          for (final item in productData) {
            productList.add(
              Product.fromMap(item as Map<String, dynamic>),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }

  void deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/delete-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
        }),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          onSuccess();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Order>> fetchAllOrders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/get-orders'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final List<dynamic> orderData = jsonDecode(res.body);
          for (final item in orderData) {
            orderList.add(
              Order.fromMap(item as Map<String, dynamic>),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return orderList;
  }

  void changeOrderStatus({
    required BuildContext context,
    required int status,
    required Order order,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/change-order-status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': order.id,
          'status': status,
        }),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: onSuccess,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<Map<String, dynamic>> getEarnings(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Sales> sales = [];
    double totalEarnings = 0;
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/analytics'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          var response = jsonDecode(res.body);
          totalEarnings = response['totalEarnings'].toDouble();
          sales = (response['categoryData'] as List)
              .map((data) => Sales.fromMap(data))
              .toList();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return {
      'sales': sales,
      'totalEarnings': totalEarnings,
    };
  }

  // Update Product
  Future<bool> updateProduct({
    required BuildContext context,
    required Product product,
    required List<String> images,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required List<Uint8List> newImages,
  }) async {
    bool isSuccess = false;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      List<String> newImageUrls = [];
      if (newImages.isNotEmpty) {
        // ko luu anh tren mongodb vi dung luong kha it(shared clutter),luu anh tren cloudinary
        final cloudinary = CloudinaryPublic('dvgeq2l6e', 'xuvwiao4');

        for (int i = 0; i < newImages.length; i++) {
          CloudinaryResponse res;
          res = await cloudinary.uploadFile(
            CloudinaryFile.fromBytesData(
              newImages[i],
              identifier:
                  'product_${product.name}_${DateTime.now().millisecondsSinceEpoch}_$i',
              folder: name,
              resourceType: CloudinaryResourceType.Image,
            ),
          );
          newImageUrls.add(res.secureUrl);
        }
      }
      List<String> updateImages =
          (newImageUrls.isNotEmpty) ? newImageUrls : images;
      http.Response res = await http.post(
        Uri.parse('$uri/seller/update-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
          'name': name,
          'description': description,
          'price': price,
          'quantity': quantity,
          'category': category,
          'images': updateImages,
        }),
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          isSuccess = true;
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return isSuccess;
  }

  Future<Map<String, dynamic>> getShopData(
      BuildContext context, String sellerId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    User? shopOwner;
    List<Product> products = [];

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/shop-data/$sellerId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          var data = jsonDecode(res.body);
          shopOwner = User.fromMap(data['shopOwner']);
          products = (data['products'] as List<dynamic>)
              .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return {
      'shopOwner': shopOwner,
      'products': products,
    };
  }

// Update getShopStats to accept sellerId
  Future<ShopStats> getShopStats(BuildContext context, String sellerId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    ShopStats stats =
        ShopStats(totalProducts: 0, avgRating: 0, followerCount: 0);

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/seller/shop-stats/$sellerId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          stats = ShopStats.fromJson(jsonDecode(res.body));
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return stats;
  }

// The follow/unfollow methods look good, but let's update the user provider after success
  Future<void> followSeller({
    required BuildContext context,
    required String sellerId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/follow'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'sellerId': sellerId,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          userProvider.followSeller(sellerId);
          showSnackBar(context, 'Successfully followed seller');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> unfollowSeller({
    required BuildContext context,
    required String sellerId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/unfollow'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'sellerId': sellerId,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          userProvider.unfollowSeller(sellerId);
          showSnackBar(context, 'Successfully unfollowed seller');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void setProductDiscount({
    required BuildContext context,
    required Product product,
    required double percentage,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/seller/set-discount'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
          'percentage': percentage,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Discount set successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get all sellers
  Future<List<User>> fetchAllSellers(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> sellerList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/sellers'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            sellerList.add(
              User.fromMap(
                jsonDecode(res.body)[i],
              ),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return sellerList;
  }

  // get all the products for buyers
  Future<List<Product>> fetchAllProductsForBuyers(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/products'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final List<dynamic> productData = jsonDecode(res.body);
          for (final item in productData) {
            productList.add(Product.fromMap(item as Map<String, dynamic>));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }
}
