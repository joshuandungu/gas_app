import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/account_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/orders_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_list_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/services/chat_service.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/cart/screens/cart_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/home/screens/home_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  static const String routeName = '/actual-home';
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottomBarBorderWidth = 5;
  int _totalUnreadMessages = 0;
  final ChatService _chatService = ChatService();
  late List<Widget> pages;
  late List<BottomNavigationBarItem> bottomNavItems;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    // Listen for chat updates to refresh the total unread count
    _chatService.connect(context);
    _chatService.listenForChatListUpdates(() {
      if (mounted) {
        _fetchUnreadCount();
      }
    });
  _initializePagesAndItems();
}


  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }



  void _initializePagesAndItems() {
    pages = [
      const HomeScreen(),
      const CartScreen(),
      const ChatListScreen(),
      const OrdersScreen(),
      const AccountScreen(),
    ];

    bottomNavItems = [
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
        label: 'Home',
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
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        label: 'Cart',
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
          child: badges.Badge(
            badgeContent: Text(
              _totalUnreadMessages.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            showBadge: _totalUnreadMessages > 0,
            child: const Icon(Icons.chat_outlined),
          ),
        ),
        label: 'Chat',
      ),
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
          child: const Icon(Icons.list_alt_outlined),
        ),
        label: 'Orders',
      ),
      BottomNavigationBarItem(
        icon: Container(
          width: bottomBarWidth,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: _page == 4
                    ? GlobalVariables.selectedNavBarColor
                    : GlobalVariables.backgroundColor,
                width: bottomBarBorderWidth,
              ),
            ),
          ),
          child: const Icon(Icons.person_outline),
        ),
        label: 'Profile',
      ),
    ];
  }

  void _fetchUnreadCount() async {
    int count = await _chatService.getTotalUnreadMessages(context);
    if (mounted) {
      setState(() => _totalUnreadMessages = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userCartLen = userProvider.user.cart.length;
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.selectedNavBarColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        backgroundColor: GlobalVariables.backgroundColor,
        iconSize: 28,
        onTap: updatePage,
        items: bottomNavItems,
      ),
    );
  }
}
