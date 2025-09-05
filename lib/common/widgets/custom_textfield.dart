import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final int maxLines;
  final bool isPass;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.textController,
    required this.hintText,
    this.maxLines = 1,
    this.isPass = false,
    required this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          ),
        ),
      ),
      validator: validator ??
          (val) {
            if (val == null || val.isEmpty) {
              return 'Enter your $hintText';
            }
            if (keyboardType == TextInputType.emailAddress) {
              final bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(val);
              if (!emailValid) return 'Please enter a valid email address';
            }
            return null;
          },
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
