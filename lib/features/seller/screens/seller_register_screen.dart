import 'dart:io';

import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_textfield.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/services/auth_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/services/seller_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class SellerRegisterScreen extends StatefulWidget {
  static const String routeName = '/seller-register-screen';
  const SellerRegisterScreen({super.key});

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final AuthService authService = AuthService();
  final SellerServices sellerServices = SellerServices();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopDescriptionController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  dynamic avatarImage;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _addressController.dispose();
  }

  void selectImage() async {
    var res = await pickImage();
    if (res != null) {
      setState(() {
        avatarImage = res;
      });
    }
  }

  void signUpSeller() {
    if (_signUpFormKey.currentState!.validate() && avatarImage != null) {
      setState(() {
        _isLoading = true;
      });
      // First, sign up the user
      authService.signUpUser(
          context: context,
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: 'seller',
          onSuccess: (email) {
            // Navigate to email verification screen with seller login redirect
            Navigator.pushNamed(
              context,
              '/user-email-verification-screen',
              arguments: {
                'email': email,
                'redirectRoute': '/seller-login-screen', // Redirect to seller login after verification
              },
            );
            // Note: After email verification, user will need to sign in manually
            // and then complete seller registration
            setState(() {
              _isLoading = false;
            });
          });
    } else if (avatarImage == null) {
      showSnackBar(context, "Please select a shop logo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Seller Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Become a Seller',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  textController: _nameController,
                  hintText: 'Full Name',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  textController: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  textController: _shopNameController,
                  hintText: 'Shop Name',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  textController: _addressController,
                  hintText: 'Shop Address (City/Town)',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  textController: _shopDescriptionController,
                  hintText: 'Shop Description',
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: selectImage,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: avatarImage != null
                          ? (kIsWeb
                              ? Image.memory(avatarImage, fit: BoxFit.cover)
                              : Image.file(avatarImage as File,
                                  fit: BoxFit.cover))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  size: 40,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Upload Shop Logo',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  textController: _passwordController,
                  hintText: 'Password',
                  isPass: true,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  textController: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  isPass: true,
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Passwords do not match!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(text: 'Sign Up', function: signUpSeller),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have a seller account? "),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
