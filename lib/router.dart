import 'package:ecommerce_app_fluterr_nodejs/common/widgets/bottom_bar.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/seller_registration_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/address/screens/address_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/address/screens/set_address.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/add_product_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_detail_screen.dart'; // This path is correct
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_chat_list_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_list_screen.dart'; // This path is correct
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/set_discount_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/shop_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/shop_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/update_product_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/auth_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/user_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/home/screens/category_deals_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/home/screens/home_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/order_details/screens/order_details_screens.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/product_details/screens/product_details_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/search/screens/search_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/order.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/product.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );
    case UserRegisterScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const UserRegisterScreen(),
      );
    case LoginSelectionScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LoginSelectionScreen(),
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomeScreen(),
      );
    case BottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BottomBar(),
      );
    case AddProductScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AddProductScreen(),
      );
    case AdminScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AdminScreen(),
      );
    case AdminLoginScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AdminLoginScreen(),
      );
    case AdminRegisterScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AdminRegisterScreen(),
      );
    case SellerLoginScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SellerLoginScreen(),
      );
    case SellerRegisterScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SellerRegisterScreen(),
      );
    case SellerScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SellerScreen(),
      );
    case SellerChatListScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SellerChatListScreen(),
      );
    case ShopProfileScreen.routeName:
      var sellerId = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ShopProfileScreen(
          sellerId: sellerId,
        ),
      );
    case SellerRegistrationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SellerRegistrationScreen(),
      );
    case CategoryDealsScreen.routeName:
      var category = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => CategoryDealsScreen(
          category: category,
        ),
      );
    case SearchScreen.routeName:
      var search = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SearchScreen(
          searchQuery: search,
        ),
      );
    case ProductDetailsScreen.routeName:
      var product = routeSettings.arguments as Product;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ProductDetailsScreen(
          product: product,
        ),
      );
    case AddressScreen.routeName:
      var args = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => AddressScreen(
          totalAmount: args['totalAmount'] as String,
          selectedItems: args['selectedItems'] as List<int>?,
          products: args['products'] as List<Product>?,
          quantities: args['quantities'] as List<int>?,
        ),
      );
    case OrderDetailsScreens.routeName:
      var order = routeSettings.arguments as Order;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => OrderDetailsScreens(
          order: order,
        ),
      );
    case UpdateProductScreen.routeName:
      var product = routeSettings.arguments as Product;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => UpdateProductScreen(
          product: product,
        ),
      );
    case SetDiscountScreen.routeName:
      var product = routeSettings.arguments as Product;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SetDiscountScreen(
          product: product,
        ),
      );
    case SetAddressScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SetAddressScreen(),
      );
    case ChatListScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ChatListScreen(),
      );
    case ChatDetailScreen.routeName:
      var args = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ChatDetailScreen(
          chatRoomId: args['chatRoomId'] as String,
          receiverName: args['receiverName'] as String,
          receiver: args['receiver'] as User,
        ),
      );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Page fault!'),
          ),
        ),
      );
  }
}
