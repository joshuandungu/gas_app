import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/shop_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/services/seller_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_detail_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';

class VendorList extends StatefulWidget {
  const VendorList({super.key});

  @override
  State<VendorList> createState() => _VendorListState();
}

class _VendorListState extends State<VendorList> {
  List<User>? vendors;
  final SellerServices sellerServices = SellerServices();

  @override
  void initState() {
    super.initState();
    fetchAllSellers();
  }

  void fetchAllSellers() async {
    vendors = await sellerServices.fetchAllSellers(context);
    if (mounted) {
      setState(() {});
    }
  }

  void navigateToShopProfile(String sellerId) {
    Navigator.pushNamed(
      context,
      ShopProfileScreen.routeName,
      arguments: sellerId,
    );
  }

  void _navigateToChatDetail(String receiverId, String receiverName) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    // Generate a chat room ID based on the user and receiver IDs
    List<String> ids = [
      currentUser.id,
      receiverId,
    ];
    ids.sort(); // Ensure consistent ordering
    String chatRoomId = ids.join(
        "_"); // e.g., userId1_userId2, which will be the same for both users

    Navigator.pushNamed(context, ChatDetailScreen.routeName, arguments: {
      'chatRoomId': chatRoomId,
      'receiverName': receiverName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return vendors == null
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vendors!.length,
              itemExtent: 90,
              itemBuilder: (context, index) {
                final vendor = vendors![index];
                return GestureDetector(
                  onTap: () =>
                      _navigateToChatDetail(vendor.id, vendor.shopName),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(vendor.shopAvatar),
                          radius: 40,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        vendor.shopName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
