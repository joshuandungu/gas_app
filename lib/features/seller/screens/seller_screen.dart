import 'package:ecommerce_app_fluterr_nodejs/common/widgets/bottom_bar.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/edit_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/services/account_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/analytics_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/services/chat_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_chat_list_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/orders_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/products_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/shop_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/services/seller_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class SellerScreen extends StatefulWidget {
  static const String routeName = '/seller-home';
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottomBarBorderWidth = 5;
  final SellerServices sellerServices = SellerServices();
  final ChatService _chatService = ChatService();
  int _totalUnreadMessages = 0;
  User? shopOwner;
  List<Widget> pages = [
    const ProductsScreen(),
    const AnalyticsScreen(),
    const OrdersScreen(),
    const SellerChatListScreen(),
  ];
  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchUnreadCount();
  }

  void _fetchUnreadCount() async {
    int count = await _chatService.getTotalUnreadMessages(context);
    if (mounted) {
      setState(() => _totalUnreadMessages = count);
    }
  }

  fetchData() async {
    // Get shop owner data and products
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final data =
        await sellerServices.getShopData(context, userProvider.user.id);
    shopOwner = data['shopOwner'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return shopOwner == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: AppBar(
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: GlobalVariables.appBarGradient,
                  ),
                ),
                title: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                          context, ShopProfileScreen.routeName,
                          arguments: userProvider.user.id),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: shopOwner!.shopAvatar.isNotEmpty
                            ? NetworkImage(shopOwner!.shopAvatar)
                            : null,
                        child: shopOwner!.shopAvatar.isEmpty
                            ? const Icon(Icons.storefront, size: 25)
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          shopOwner!.shopName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.menu_rounded),
                      position: PopupMenuPosition.under,
                      offset: const Offset(0, 5),
                      onSelected: (value) {
                        if (value == 'profile') {
                          Navigator.pushNamed(
                              context, EditProfileScreen.routeName);
                        } else if (value == 'homepage') {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            BottomBar.routeName,
                            (route) =>
                                false, // This will show the home screen (index 0) by default
                          );
                        } else if (value == 'logout') {
                          AccountServices().logOut(
                            context,
                            logoutRedirectRouteName: LoginScreen.routeName,
                            role: 'seller',
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: ListTile(
                            title: Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            leading: Icon(Icons.person_outline),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'homepage',
                          child: ListTile(
                            title: Text(
                              'Return homepage',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            leading: Icon(Icons.home_outlined),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: ListTile(
                            title: Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.redAccent,
                              ),
                            ),
                            leading: Icon(Icons.logout),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: pages[_page],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _page,
              selectedItemColor: GlobalVariables.selectedNavBarColor,
              unselectedItemColor: GlobalVariables.unselectedNavBarColor,
              backgroundColor: GlobalVariables.backgroundColor,
              iconSize: 28,
              onTap: updatePage,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    width: bottomBarWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _page == 0
                              ? GlobalVariables.selectedNavBarColor
                              : GlobalVariables.backgroundColor,
                          width: bottomBarBorderWidth,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.home_outlined),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    width: bottomBarWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _page == 1
                              ? GlobalVariables.selectedNavBarColor
                              : GlobalVariables.backgroundColor,
                          width: bottomBarBorderWidth,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.analytics_outlined),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    width: bottomBarWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _page == 2
                              ? GlobalVariables.selectedNavBarColor
                              : GlobalVariables.backgroundColor,
                          width: bottomBarBorderWidth,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.all_inbox_outlined),
                  ),
                  label: '',
                ),
                // CHATS
                BottomNavigationBarItem(
                  icon: Container(
                    width: bottomBarWidth,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _page == 3
                              ? GlobalVariables.selectedNavBarColor
                              : GlobalVariables.backgroundColor,
                          width: bottomBarBorderWidth,
                        ),
                      ),
                    ),
                    child: badges.Badge(
                      showBadge: _totalUnreadMessages > 0,
                      badgeContent: Text(_totalUnreadMessages.toString()),
                      badgeStyle: const badges.BadgeStyle(
                        elevation: 0,
                        badgeColor: Colors.red,
                      ),
                      position: badges.BadgePosition.topEnd(top: -12, end: -12),
                      child: const Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                  label: '',
                ),
              ],
            ),
          );
  }
}
