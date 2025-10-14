import 'package:ecommerce_app_fluterr_nodejs/common/widgets/bottom_bar.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/about_app_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/account_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/customer_care_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/edit_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/notifications_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/orders_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/seller_registration_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/account/screens/settings_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/address/screens/address_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/login_selection_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/address/screens/set_address.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/customer_queries_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/system_settings_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/add_product_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_detail_screen.dart'; // This path is correct
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_chat_list_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/chat/screens/chat_list_screen.dart'; // This path is correct
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/set_discount_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/shop_profile_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/seller_request_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/seller/screens/update_product_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/user_register_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/auth/screens/user_email_verification_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/admin/screens/admin_email_verification_screen.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/home/screens/all_products_screen.dart';
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
    case LoginScreen.routeName:
      var role = routeSettings.arguments as String?;
      if (role == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Role not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => LoginScreen(role: role),
      );
    case UserRegisterScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const UserRegisterScreen(),
      );
    case UserEmailVerificationScreen.routeName:
      var args = routeSettings.arguments;
      if (args == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Email verification arguments not provided'),
            ),
          ),
        );
      }
      if (args is Map<String, dynamic>) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => UserEmailVerificationScreen.fromArguments(args),
        );
      } else {
        // Fallback for string arguments (backward compatibility)
        var email = args as String?;
        if (email == null) {
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: Email not provided'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => UserEmailVerificationScreen(email: email),
        );
      }
    case AdminEmailVerificationScreen.routeName:
      var email = routeSettings.arguments as String?;
      if (email == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Admin email not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => AdminEmailVerificationScreen(email: email),
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
    case AllProductsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AllProductsScreen(),
      );
    case BottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BottomBar(),
      );
    case EditProfileScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const EditProfileScreen(),
      );
    case '/account':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AccountScreen(),
      );
    case '/orders':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const OrdersScreen(),
      );
    case AboutAppScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AboutAppScreen(),
      );
    case SettingsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SettingsScreen(),
      );
    case NotificationsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const NotificationsScreen(),
      );
    case CustomerCareScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CustomerCareScreen(),
      );
    case '/seller-orders':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const OrdersScreen(),
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
    case AdminRegisterScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AdminRegisterScreen(),
      );
    case SellerRegisterScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SellerRegisterScreen(),
      );
    case '/seller-request-screen':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SellerRequestScreen(),
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
      var sellerId = routeSettings.arguments as String?;
      if (sellerId == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Seller ID not provided'),
            ),
          ),
        );
      }
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
      var category = routeSettings.arguments as String?;
      if (category == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Category not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => CategoryDealsScreen(
          category: category,
        ),
      );
    case SearchScreen.routeName:
      var search = routeSettings.arguments as String?;
      if (search == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Search query not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SearchScreen(
          searchQuery: search,
        ),
      );
    case ProductDetailsScreen.routeName:
      var product = routeSettings.arguments as Product?;
      if (product == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Product not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ProductDetailsScreen(
          product: product,
        ),
      );
    case AddressScreen.routeName:
      var args = routeSettings.arguments as Map<String, dynamic>?;
      if (args == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Address screen arguments not provided'),
            ),
          ),
        );
      }
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
      var order = routeSettings.arguments as Order?;
      if (order == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Order not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => OrderDetailsScreens(
          order: order,
        ),
      );
    case UpdateProductScreen.routeName:
      var product = routeSettings.arguments as Product?;
      if (product == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Product not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => UpdateProductScreen(
          product: product,
        ),
      );
    case SetDiscountScreen.routeName:
      var product = routeSettings.arguments as Product?;
      if (product == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Product not provided'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SetDiscountScreen(
          product: product,
        ),
      );
    case SystemSettingsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SystemSettingsScreen(),
      );
    case CustomerQueriesScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CustomerQueriesScreen(),
      );
    case SetAddressScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SetAddressScreen(),
      );
    case ChatListScreen.routeName:
      var args = routeSettings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ChatListScreen(initialView: args?['view']),
      );
    case ChatDetailScreen.routeName:
      var args = routeSettings.arguments as Map<String, dynamic>?;
      if (args == null) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Chat detail arguments not provided'),
            ),
          ),
        );
      }
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
