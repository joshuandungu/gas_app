import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class MpesaPhoneDialog extends StatefulWidget {
  final Function(String phoneNumber) onConfirm;

  const MpesaPhoneDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<MpesaPhoneDialog> createState() => _MpesaPhoneDialogState();
}

class _MpesaPhoneDialogState extends State<MpesaPhoneDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter M-Pesa Phone Number'),
      content: Form(
        key: _formKey,
        child: CustomTextField(
          textController: _phoneController,
          hintText: 'e.g., 0712345678',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            final phoneRegExp = RegExp(r'^\d{9,12}$');
            if (!phoneRegExp.hasMatch(value)) {
              return 'Enter a valid phone number (9-12 digits)';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onConfirm(_phoneController.text);
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
