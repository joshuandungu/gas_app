import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Profile fields
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _shopNameController = TextEditingController();

  bool _isVendor = false;
  bool _isRequestingVendor = false;
  bool _isLoading = true;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _firstNameController.text = userDoc['firstName'] ?? '';
            _middleNameController.text = userDoc['middleName'] ?? '';
            _lastNameController.text = userDoc['lastName'] ?? '';
            _idNumberController.text = userDoc['idNumber'] ?? '';
            _phoneController.text = userDoc['phone'] ?? '';
            _ageController.text = userDoc['age']?.toString() ?? '';
            _locationController.text = userDoc['location'] ?? '';
            _shopNameController.text = userDoc['shopName'] ?? '';
            _isVendor = userDoc['role'] == 'vendor';
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'idNumber': _idNumberController.text.trim(),
          'phone': _phoneController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'location': _locationController.text.trim(),
          'shopName': _shopNameController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
    }
  }

  Future<void> _requestVendorAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isRequestingVendor = true);

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'vendorRequestStatus': 'pending',
          'vendorStatus': 'pending',
          'isVendor': false,
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'idNumber': _idNumberController.text.trim(),
          'phone': _phoneController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'location': _locationController.text.trim(),
          'shopName': _shopNameController.text.trim(),
          'email': user.email,
          'requestedAt': FieldValue.serverTimestamp(),
          'role': 'buyer',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Vendor request sent. Awaiting admin approval.")),
        );
      }
    } catch (e) {
      debugPrint("Error requesting vendor: $e");
    }

    if (!mounted) return;
    setState(() => _isRequestingVendor = false);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/default_avatar.png'),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter first name' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _middleNameController,
                      label: 'Middle Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter last name' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _idNumberController,
                      label: 'ID Number',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter ID number';
                        if (v.length != 8 && v.length != 10) {
                          return 'ID must be 8 or 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your age' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _locationController,
                      label: 'Location/Address',
                      icon: Icons.location_on,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Enter your address'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _shopNameController,
                      label: 'Gas Shop Name',
                      icon: Icons.store,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter shop name' : null,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _updateProfile,
                    ),
                    const SizedBox(height: 30),

                    _isVendor
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(50),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.store, color: Colors.green),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "You are a Vendor. Vendor privileges enabled.",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : OutlinedButton.icon(
                            icon: _isRequestingVendor
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.store),
                            label: const Text("Request Vendor Account"),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: _isRequestingVendor
                                ? null
                                : _requestVendorAccount,
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
