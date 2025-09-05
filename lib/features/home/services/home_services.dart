import 'dart:convert';

import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/product.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeServices {
  // Helper method to reduce code duplication for fetching products
  Future<List<Product>> _fetchProducts({
    required BuildContext context,
    required String url,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          var jsonData = jsonDecode(res.body) as List;
          productList = jsonData.map((item) {
            // Flatten the nested sellerId object for easier use in the Product model
            if (item['sellerId'] != null && item['sellerId'] is Map) {
              item['shopName'] = item['sellerId']['shopName']?.toString() ?? '';
              item['shopAvatar'] =
                  item['sellerId']['shopAvatar']?.toString() ?? '';
              item['sellerId'] = item['sellerId']['_id']?.toString() ?? '';
            }
            return Product.fromMap(item);
          }).toList();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }

  Future<List<Product>> fetchCategoryProducts({
    required BuildContext context,
    required String category,
  }) async {
    return _fetchProducts(
        context: context, url: '$uri/api/products?category=$category');
  }

  Future<List<Product>> fetchDealOfDay({
    required BuildContext context,
  }) async {
    return _fetchProducts(context: context, url: '$uri/api/deal-of-day');
  }

  Future<List<User>> fetchTopSellers(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> sellers = [];
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
          for (var sellerData in jsonDecode(res.body)) {
            sellers.add(User.fromMap(sellerData));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return sellers;
  }
}
