import 'dart:convert';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/bottom_bar.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/error_handling.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // sign up user
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String role,
    double? latitude,
    double? longitude,
    String? phone,
    Function(String email, String userId)? onSuccess,
  }) async {
    if (!(await hasInternetConnection())) {
      showSnackBar(context, 'No internet connection');
      return;
    }
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'latitude': latitude,
          'longitude': longitude,
          'phoneNumber': phone,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (!context.mounted) return;
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (onSuccess != null) {
            final userId = jsonDecode(res.body)['_id'];
            onSuccess(email, userId);
          } else {
            showSnackBar(context, 'Account has been successfully created!');
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // sign in user
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
    required String role,
  }) async {
    if (!(await hasInternetConnection())) {
      showSnackBar(context, 'No internet connection');
      return;
    }
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (!context.mounted) return;
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          final userData = jsonDecode(res.body);
          if (userData['status'] != 'active') {
            showSnackBar(context, 'Your account is pending approval by admin.');
            return;
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);
          await prefs.setString('x-auth-token', userData['token']);
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          String routeName = BottomBar.routeName;
          if (userProvider.user.type == 'admin') {
            routeName = AdminScreen.routeName;
          } else if (userProvider.user.type == 'seller') {
            routeName = SellerScreen.routeName;
          }
          Navigator.pushNamedAndRemoveUntil(
            context,
            routeName,
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data
  void getUserData(
    BuildContext context,
  ) async {
    if (!(await hasInternetConnection())) {
      showSnackBar(context, 'No internet connection');
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      if (token == null) {
        prefs.setString('x-auth-token', '');
      }
      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!
        },
      );
      var response = jsonDecode(tokenRes.body);
      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        if (!context.mounted) return; // Add this check
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  // reset password request
  Future<String?> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    if (!(await hasInternetConnection())) {
      showSnackBar(context, 'No internet connection');
      return null;
    }
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/reset-password'),
        body: jsonEncode({'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return null;

      String? token;
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Reset token generated successfully!',
          );
          // Lấy token từ response
          token = jsonDecode(res.body)['resetToken'];
        },
      );
      return token;
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
      return null;
    }
  }

  // update password
  Future<bool> updatePassword({
    required BuildContext context,
    required String resetToken,
    required String newPassword,
  }) async {
    if (!(await hasInternetConnection())) {
      showSnackBar(context, 'No internet connection');
      return false;
    }
    bool success = false;
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/update-password'),
        body: jsonEncode({
          'resetToken': resetToken,
          'newPassword': newPassword,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return false;
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Password updated successfully!');
          success = true;
        },
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
    return success;
  }

  // verify email
  void verifyEmail({
    required BuildContext context,
    required String email,
    required String code,
    Function()? onSuccess,
  }) async {
    if (!(await hasInternetConnection())) {
      showSnackBar(context, 'No internet connection');
      return;
    }
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/verify-email'),
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (!context.mounted) return;
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (onSuccess != null) {
            onSuccess();
          } else {
            showSnackBar(context, 'Email verified successfully!');
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // resend verification code
  void resendVerificationCode({
    required BuildContext context,
    required String email,
  }) async {
    if (!(await hasInternetConnection())) {
      showSnackBar(context, 'No internet connection');
      return;
    }
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/resend-verification-code'),
        body: jsonEncode({
          'email': email,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (!context.mounted) return;
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'A new verification code has been sent.');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
