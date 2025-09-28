import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/models/seller_request.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/seller_stats.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';

class AdminServices {
  Future<List<SellerRequest>> fetchSellerRequests(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<SellerRequest> requests = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/seller-requests'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          var decodedData = jsonDecode(res.body) as List;
          requests = decodedData.map((item) {
            // Ensure createdAt is in the correct format
            if (item['createdAt'] is Map) {
              item['createdAt'] = DateTime.fromMillisecondsSinceEpoch(
                item['createdAt']['\$date'],
              ).toIso8601String();
            }
            return SellerRequest.fromMap(item);
          }).toList();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return requests;
  }

  Future<void> processSellerRequest({
    required BuildContext context,
    required String requestId,
    required String status,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/process-seller-request'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'requestId': requestId,
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

  Future<List<User>> fetchSellers(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> sellers = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/sellers'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (var seller in jsonDecode(res.body)) {
            sellers.add(User.fromMap(seller));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return sellers;
  }

  Future<List<User>> fetchUsers(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> users = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/users'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (var user in jsonDecode(res.body)) {
            users.add(User.fromMap(user));
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return users;
  }

  Future<void> suspendSeller({
    required BuildContext context,
    required String sellerId,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/suspend-seller'),
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
        onSuccess: onSuccess,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> deleteSeller({
    required BuildContext context,
    required String sellerId,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.delete(
        Uri.parse('$uri/admin/seller/$sellerId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
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

  Future<void> suspendUser({
    required BuildContext context,
    required String userId,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/suspend-user'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'userId': userId,
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

  Future<void> deleteUser({
    required BuildContext context,
    required String userId,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.delete(
        Uri.parse('$uri/admin/user/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
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

  Future<List<SellerStats>> getBestSellers({
    required BuildContext context,
    required int month,
    required int year,
    String? category,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      String url = '$uri/admin/best-sellers?month=$month&year=$year';
      if (category != null) {
        url += '&category=$category';
      }

      http.Response res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {},
      );

      List<SellerStats> sellers = (jsonDecode(res.body) as List)
          .map((data) => SellerStats.fromMap(data))
          .toList();

      return sellers;
    } catch (e) {
      showSnackBar(context, e.toString());
      return [];
    }
  }
}
