import 'package:ecommerce_app_fluterr_nodejs/features/home/services/home_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/shop_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:flutter/material.dart';

class TopSellers extends StatefulWidget {
  const TopSellers({super.key});

  @override
  State<TopSellers> createState() => _TopSellersState();
}

class _TopSellersState extends State<TopSellers> {
  List<User>? sellers;
  final HomeServices homeServices = HomeServices();

  @override
  void initState() {
    super.initState();
    fetchTopSellers();
  }

  void fetchTopSellers() async {
    // NOTE: This assumes a `fetchTopSellers` method exists in your HomeServices
    // to retrieve a list of sellers.
    sellers = await homeServices.fetchTopSellers(context);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sellers == null) {
      // You can return a loading indicator like a shimmer effect here
      return const Center(child: CircularProgressIndicator());
    }
    if (sellers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            'Top Sellers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sellers!.length,
            itemBuilder: (context, index) {
              final seller = sellers![index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ShopProfileScreen.routeName,
                    arguments: seller.id,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      left: index == 0 ? 15.0 : 10.0,
                      right: index == sellers!.length - 1 ? 15.0 : 0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(seller.shopAvatar),
                        radius: 35,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          seller.shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
