import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gas/models/user_model.dart';
import 'package:gas/screens/home/home_Ads/edit_profile_screen.dart';
import 'package:gas/screens/home/home_Ads/change_password_screen.dart';
// Removed payment_methods_screen.dart import
import 'package:gas/screens/home/home_Ads/addresses_screen.dart';
import 'package:gas/screens/home/home_Ads/notifications_screen.dart';
import 'package:gas/screens/home/home_Ads/theme_appearance_screen.dart';
import 'package:gas/screens/home/home_Ads/language_screen.dart';
import 'package:gas/screens/home/home_Ads/privacy_policy_screen.dart';
import 'package:gas/screens/home/home_Ads/terms_of_service_screen.dart';
import 'package:gas/screens/home/home_Ads/about_app_screen.dart';

// ✅ New vendor imports
import 'package:gas/screens/home/home_Ads/vendor/post_gas_screen.dart';
import 'package:gas/screens/home/home_Ads/vendor/vendor_gas_listings_screen.dart';
import 'package:gas/screens/home/home_Ads/vendor/withdraw_funds_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _userRole;
  UserModel? _currentUser; // Declare _currentUser
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _userRole = doc['role'] ?? 'user';
            _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>); // Set _currentUser
          });
        } else {
          setState(() {
            _userRole = 'user';
            _currentUser = null; // No user data found
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user role: $e");
      _userRole = 'user';
      _currentUser = null;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'Account Settings'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          // ❌ Removed Payment Methods tile here
          _buildSettingsTile(
            context,
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressesScreen()),
              );
            },
          ),

          _buildSectionTitle(context, 'App Preferences'),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NotificationScreen(currentUser: _currentUser!)),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.color_lens_outlined,
            title: 'Theme & Appearance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ThemeAppearanceScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: 'Language',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );
            },
          ),

          _buildSectionTitle(context, 'Legal & About'),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              );
            },
          ),

          // ✅ Vendor Section
          if (_userRole == 'vendor') ...[
            _buildSectionTitle(context, 'Vendor Panel'),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0xFF * 0.1).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You are a Verified Vendor",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.add_business,
              title: 'Post',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostGasScreen()),
                );
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.inventory,
              title: 'Manage My Listings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VendorGasListingsScreen(currentUser: _currentUser!)),
                );
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Withdraw Funds',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WithdrawFundsScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
