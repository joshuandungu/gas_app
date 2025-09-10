import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/account_screen.dart';

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
  List<Widget> pages = [
    const HomeScreen(),
    const CartScreen(),
    const ChatListScreen(),
    const AccountScreen(),
  ];
  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

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
  }

  void _fetchUnreadCount() async {
    int count = await _chatService.getTotalUnreadMessages(context);
    if (mounted) {
      setState(() => _totalUnreadMessages = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userCartLen = context.watch<UserProvider>().user.cart.length;
    return Scaffold(
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
          // CART
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
              child: badges.Badge(
                badgeContent: Text(userCartLen.toString()),
                badgeStyle: const badges.BadgeStyle(
                  elevation: 0,
                  badgeColor: Colors.white,
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            label: '',
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
          // ACCOUNT
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
              child: const Icon(Icons.person_outline_outlined),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
