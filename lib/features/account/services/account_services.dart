import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/notification.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart' show User;
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountServices {
  Future<void> updateUserProfile(
    BuildContext context, {
    required String name,
    required String email,
    String? phoneNumber,
    String? address,
    String? shopName,
    String? shopDescription,
    dynamic newAvatar,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      String? avatarUrl;
      if (newAvatar != null) {
        final cloudinary = CloudinaryPublic('dvgeq2l6e', 'xuvwiao4');
        CloudinaryResponse res;
        if (kIsWeb) {
          res = await cloudinary.uploadFile(
            CloudinaryFile.fromBytesData(
              newAvatar,
              identifier:
                  'shop_avatar_${userProvider.user.id}_${DateTime.now().millisecondsSinceEpoch}',
              folder: shopName ?? userProvider.user.shopName,
            ),
          );
        } else {
          res = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              (newAvatar as File).path,
              folder: shopName ?? userProvider.user.shopName,
            ),
          );
        }
        avatarUrl = res.secureUrl;
      }

      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (address != null) 'address': address,
        if (shopName != null) 'shopName': shopName,
        if (shopDescription != null) 'shopDescription': shopDescription,
        if (avatarUrl != null) 'shopAvatar': avatarUrl,
      };

      http.Response res = await http.post(
        Uri.parse('$uri/api/update-profile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(body),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Update user provider with new data
          User newUser = userProvider.user.copyWith(
            name: name,
            email: email,
            phoneNumber: phoneNumber ?? userProvider.user.phoneNumber,
            address: address ?? userProvider.user.address,
            shopName: shopName ?? userProvider.user.shopName,
            shopDescription:
                shopDescription ?? userProvider.user.shopDescription,
            shopAvatar: avatarUrl ?? userProvider.user.shopAvatar,
          );
          userProvider.setUserFromModel(newUser);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }

  Future<List<Order>> fetchOrders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/orders/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      if (!context.mounted) return [];

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
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
    return orderList;
  }

  // Other methods from AccountServices...
  void logOut(BuildContext context,
      {String logoutRedirectRouteName = LoginSelectionScreen.routeName,
      String? role}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('x-auth-token', '');
      Navigator.pushNamedAndRemoveUntil(
        context,
        logoutRedirectRouteName,
        arguments: role,
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Placeholder for other methods
  Future<List<Notification_Model>> fetchNotifications(
          BuildContext context) async =>
      [];
  Future<void> markNotificationAsRead(BuildContext context, String id) async {}
  Future<void> markAllNotificationsAsRead(BuildContext context) async {}
  Future<void> deleteNotification(BuildContext context, String id) async {}
  Future<void> deleteAllNotifications(BuildContext context) async {}
  Future<void> clearOldNotifications(BuildContext context, int days) async {}

  Future<Map<String, String>> fetchAboutApp(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Map<String, String> aboutData = {};
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/about-app'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      if (!context.mounted) return {};

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          aboutData = Map<String, String>.from(jsonDecode(res.body));
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
    return aboutData;
  }

  Future<void> updateAboutApp(BuildContext context, Map<String, String> aboutData) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/update-about-app'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode(aboutData),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {},
      );
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }
}
