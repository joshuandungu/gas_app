import 'dart:convert';

import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  if (response.statusCode == 200) {
    onSuccess();
    return;
  }

  String message = 'An unknown error occurred.';
  try {
    final body = jsonDecode(response.body);
    message = body['msg'] ?? body['error'] ?? 'Error: ${response.statusCode}';
  } catch (e) {
    // If the body is not valid JSON or doesn't contain a message, use the reason phrase.
    message = response.reasonPhrase ?? 'Error: ${response.statusCode}';
  }

  if (context.mounted) {
    showSnackBar(context, message);
  }
}
