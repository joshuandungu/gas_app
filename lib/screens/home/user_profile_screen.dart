import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // Pass from login or backend fetch

  const UserProfileScreen({super.key, required this.userData});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final Color primaryColor = const Color(0xFF00C853);

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 10),
          _buildSectionTitle("Personal Information"),
          _buildInfoTile(Icons.person_outline, "Full Name", user['fullName']),
          _buildInfoTile(Icons.email_outlined, "Email", user['email']),
          _buildInfoTile(Icons.phone_outlined, "Phone", user['phone']),
          _buildInfoTile(Icons.location_on_outlined, "Address", user['address']),
          const SizedBox(height: 10),
          _buildSectionTitle("Account Settings"),
          _buildMenuTile(Icons.lock_outline, "Change Password", () {}),
          _buildMenuTile(Icons.payment_outlined, "Payment Methods", () {}),
          _buildMenuTile(Icons.receipt_long_outlined, "My Orders", () {}),
          _buildMenuTile(Icons.favorite_border, "Wishlist", () {}),
          const SizedBox(height: 10),
          _buildSectionTitle("Support"),
          _buildMenuTile(Icons.help_outline, "Help & Support", () {}),
          _buildMenuTile(Icons.policy_outlined, "Terms & Conditions", () {}),
          _buildMenuTile(Icons.privacy_tip_outlined, "Privacy Policy", () {}),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: Logout logic
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user['profileImage'] != null
                ? NetworkImage(user['profileImage'])
                : null,
            child: user['profileImage'] == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['fullName'] ?? "User Name",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user['email'] ?? "",
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(user['phone'] ?? "",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String? value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(label),
        subtitle: Text(value ?? "Not set"),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
