import 'dart:convert';

import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/auth_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/notification.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountServices {
  Future<List<Order>?> fetchOrders(BuildContext context) async {
    List<Order> orderList = [];
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      http.Response res = await http.get(
        Uri.parse('$uri/api/orders/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      if (!context.mounted) return null; // Check if context is still valid

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final List<dynamic> orderData = jsonDecode(res.body);
          for (var item in orderData) {
            orderList.add(
              // Directly use the map, assuming Order.fromMap exists
              Order.fromMap(item as Map<String, dynamic>),
            );
          }
        },
      );
      // Only return the list if the request was successful (status 200)
      if (res.statusCode == 200) {
        return orderList;
      }
      return null; // Return null on HTTP error to trigger error UI
    } catch (e) {
      if (context.mounted)
        showSnackBar(context, 'Failed to load orders: ${e.toString()}');
      return null;
    }
  }

  // log out
  void logOut(BuildContext context,
      {required String logoutRedirectRouteName}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('x-auth-token', '');
      Navigator.pushNamedAndRemoveUntil(
          context, logoutRedirectRouteName, (route) => false);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Notification_Model>> fetchNotifications(
      BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Notification_Model> notifications = [];
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/notifications'),
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
            notifications.add(
              Notification_Model.fromMap(
                jsonDecode(res.body)[i],
              ),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return notifications;
  }

  Future<void> markNotificationAsRead(
    BuildContext context,
    String notificationId,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/notifications/mark-read/$notificationId'),
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
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> markAllNotificationsAsRead(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/notifications/mark-all-read'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'All notifications marked as read');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> deleteNotification(
      BuildContext context, String notificationId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.delete(
        Uri.parse('$uri/api/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Optional: Show a snackbar for deletion
          showSnackBar(context, 'Notification deleted');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> deleteAllNotifications(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.delete(
        Uri.parse('$uri/api/notifications-all'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'All notifications deleted');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> clearOldNotifications(BuildContext context, int days) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      http.Response res = await http.delete(
        Uri.parse('$uri/api/notifications-old?days=$days'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final Map<String, dynamic> response = jsonDecode(res.body);
          showSnackBar(context, response['msg']);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateUserProfile(
    BuildContext context, {
    String? name,
    String? email,
    String? address,
    String? shopName,
    String? shopDescription,
    String? shopAvatar,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (address != null) body['address'] = address;
      if (shopName != null) body['shopName'] = shopName;
      if (shopDescription != null) body['shopDescription'] = shopDescription;
      if (shopAvatar != null) body['shopAvatar'] = shopAvatar;

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
          // Update local user data
          final updatedUser = User.fromMap(jsonDecode(res.body));
          userProvider.setUserFromModel(updatedUser);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
