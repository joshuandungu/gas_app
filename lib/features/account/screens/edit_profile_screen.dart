import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _shopNameController;
  late TextEditingController _shopDescriptionController;
  late TextEditingController _shopAvatarController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _addressController = TextEditingController(text: user.address);
    _shopNameController = TextEditingController(text: user.shopName);
    _shopDescriptionController = TextEditingController(text: user.shopDescription);
    _shopAvatarController = TextEditingController(text: user.shopAvatar);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _shopAvatarController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final accountServices = AccountServices();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      if (userProvider.user.type == 'seller') {
        await accountServices.updateUserProfile(
          context,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          shopName: _shopNameController.text.trim(),
          shopDescription: _shopDescriptionController.text.trim(),
          shopAvatar: _shopAvatarController.text.trim(),
        );
      } else {
        await accountServices.updateUserProfile(
          context,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                if (user.type != 'seller') ...[
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your address' : null,
                  ),
                ],
                if (user.type == 'seller') ...[
                  TextFormField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your shop name' : null,
                  ),
                  TextFormField(
                    controller: _shopDescriptionController,
                    decoration: const InputDecoration(labelText: 'Shop Description'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your shop description' : null,
                  ),
                  TextFormField(
                    controller: _shopAvatarController,
                    decoration: const InputDecoration(labelText: 'Shop Avatar URL'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your shop avatar URL';
                      }
                      final urlRegex = RegExp(r'^https?://');
                      if (!urlRegex.hasMatch(value)) {
                        return 'Please enter a valid URL';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
