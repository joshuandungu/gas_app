import 'dart:io';
import 'dart:typed_data';

import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_button.dart';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_textfield.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/services/seller_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class SellerRequestScreen extends StatefulWidget {
  static const String routeName = '/seller-request-screen';
  const SellerRequestScreen({super.key});

  @override
  State<SellerRequestScreen> createState() => _SellerRequestScreenState();
}

class _SellerRequestScreenState extends State<SellerRequestScreen> {
  final _requestFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final SellerServices sellerServices = SellerServices();

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopDescriptionController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Uint8List? avatarImage;

  @override
  void initState() {
    super.initState();
    // Pre-fill phone number if user already has one
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user.phoneNumber.isNotEmpty) {
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
  }

  void selectImage() async {
    var res = await pickImage();
    if (res != null) {
      setState(() {
        avatarImage = res;
      });
    }
  }

  void submitSellerRequest() async {
    if (_requestFormKey.currentState!.validate() && avatarImage != null) {
      setState(() {
        _isLoading = true;
      });
      // Get current location
      Position? position = await getCurrentLocation();
      if (position == null) {
        showSnackBar(context, 'Unable to get location. Please enable location services.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await sellerServices.requestSellerStatus(
        context: context,
        shopName: _shopNameController.text,
        shopDescription: _shopDescriptionController.text,
        address: _addressController.text,
        avatar: avatarImage!,
        userId: userProvider.user.id,
        latitude: position.latitude,
        longitude: position.longitude,
        phone: _phoneController.text,
      );

      setState(() {
        _isLoading = false;
      });
    } else if (avatarImage == null) {
      showSnackBar(context, "Please select a shop logo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _requestFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request to Become a Seller',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fill in the details below to submit your seller request. Your request will be processed automatically.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  textController: _phoneController,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
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
                          ? Image.memory(avatarImage!, fit: BoxFit.cover)
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
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(text: 'Submit Request', function: submitSellerRequest),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
