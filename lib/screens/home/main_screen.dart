import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

import 'package:gas/models/user_model.dart';
import 'package:gas/screens/home/cart_screen.dart' as cart;
import 'package:gas/screens/home/services_screen.dart';
import 'package:gas/screens/home/messages_screen.dart';
import 'package:gas/screens/home/home_Ads/settings_screen.dart';
import 'package:gas/screens/home/home_Ads/notifications_screen.dart';
import 'package:gas/config/app_routes.dart';
import 'package:gas/screens/home/orders_screen.dart';
import 'package:gas/screens/home/home_Ads/order_now_screen.dart';

/// ✅ Shared cart manager (local memory)
class CartManager {
  static final List<Map<String, dynamic>> _cartItems = [];

  static List<Map<String, dynamic>> get items => _cartItems;

  static void addItem(Map<String, dynamic> product) {
    _cartItems.add(product);
  }

  static void removeItem(Map<String, dynamic> product) {
    _cartItems.remove(product);
  }

  static void clearCart() {
    _cartItems.clear();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color primaryColor = const Color(0xFF00C853);
  int _currentIndex = 0;
  UserModel? _user;
  bool _isLoading = true;

  late List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _user = UserModel.fromMap(doc.data()!);
          _isLoading = false;

          _pages = [
            HomeContent(
              user: _user!,
              primaryColor: primaryColor,
              onLogout: _handleLogout,
            ),
            ServicesScreen(currentUser: _user!),
            MessagesScreen(currentUser: _user!),
            OrdersScreen(currentUser: _user!), // ✅ Orders tab added
          ];
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoute.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle_outlined),
          activeIcon: Icon(Icons.build_circle),
          label: "Services",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: "Messages",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: "Orders",
        ),
      ],
    );
  }
}

class HomeContent extends StatefulWidget {
  final UserModel user;
  final Color primaryColor;
  final VoidCallback onLogout;

  const HomeContent({
    super.key,
    required this.user,
    required this.primaryColor,
    required this.onLogout,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  static const String BACKEND_BASE = 'http://192.168.40.70:5000';

  String selectedCategory = "All";
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Future<List<dynamic>> _allProductsFuture;

  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.all_inclusive},
    {"name": "Gas", "icon": Icons.local_gas_station},
    {"name": "Bulk", "icon": Icons.storage},
    {"name": "Cylinder", "icon": Icons.swap_horiz},
    {"name": "Subscription", "icon": Icons.subscriptions},
    {"name": "Corporate", "icon": Icons.business},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<List<dynamic>> _fetchData(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> _fetchAllData() async {
    List<String> endpoints = [
      "$BACKEND_BASE/api/gas-products",
      "$BACKEND_BASE/api/bulk-gas",
      "$BACKEND_BASE/api/cylinder-exchange",
      "$BACKEND_BASE/api/subscriptions",
      "$BACKEND_BASE/api/corporate-supply",
    ];

    List<dynamic> allProducts = [];
    for (var endpoint in endpoints) {
      final data = await _fetchData(endpoint);
      allProducts.addAll(data);
    }
    return allProducts;
  }

  void _loadData() {
    if (selectedCategory == "All") {
      _allProductsFuture = _fetchAllData();
    } else {
      _allProductsFuture = _fetchData(_getApiEndpoint(selectedCategory));
    }
  }

  String _getApiEndpoint(String category) {
    switch (category) {
      case "Gas":
        return "$BACKEND_BASE/api/gas-products";
      case "Bulk":
        return "$BACKEND_BASE/api/bulk-gas";
      case "Cylinder":
        return "$BACKEND_BASE/api/cylinder-exchange";
      case "Subscription":
        return "$BACKEND_BASE/api/subscriptions";
      case "Corporate":
        return "$BACKEND_BASE/api/corporate-supply";
      default:
        return "$BACKEND_BASE/api/all-products";
    }
  }

  Future<void> _reloadData() async {
    setState(() {
      _loadData();
    });
  }

  void _shareProduct(Map<String, dynamic> product) {
    final shareText =
        "🔥 Check out this gas product: ${product['title'] ?? 'Product'}\n"
        "💰 Price: KSh ${product['price'] ?? 'N/A'}\n"
        "📄 Description: ${product['description'] ?? 'No description available'}\n"
        "📍 Available at: ${product['location'] ?? 'Location not specified'}\n\n"
        "Download our app to order now!";
    Share.share(shareText);
  }

  void _addToCart(Map<String, dynamic> product) {
    CartManager.addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added to cart!')),
    );
    setState(() {}); // refresh badge count
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: widget.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: TextField(
          controller: searchController,
          onChanged: (val) {
            setState(() => searchQuery = val.toLowerCase());
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search gas, vendors...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationScreen(currentUser: widget.user),
                ),
              );
            },
          ),
          IconButton(
            icon: Badge(
              backgroundColor: Colors.red,
              label: Text('${CartManager.items.length}',
                  style: const TextStyle(color: Colors.white)),
              child: const Icon(Icons.shopping_cart_outlined,
                  color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => cart.CartScreen(
                    currentUser: widget.user,
                    items: CartManager.items,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _reloadData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildCategoryButtons(isWeb)),
            _buildProductsList(isWeb),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: widget.primaryColor),
            accountName: Text(widget.user.name),
            accountEmail: Text(widget.user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.user.name[0].toUpperCase(),
                  style: TextStyle(color: widget.primaryColor, fontSize: 24)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("Orders"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrdersScreen(currentUser: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: widget.onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons(bool isWeb) {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['name'];
                _loadData();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? widget.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    category['icon'],
                    size: 18,
                    color: isSelected ? Colors.white : widget.primaryColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsList(bool isWeb) {
    return SliverToBoxAdapter(
      child: FutureBuilder<List<dynamic>>(
        future: _allProductsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          var products = snapshot.data ?? [];

          if (searchQuery.isNotEmpty) {
            products = products
                .where((p) =>
                    (p['title'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery) ||
                    (p['vendorShopName'] ??
                            p['vendor_shop_name'] ??
                            p['shop_name'] ??
                            '')
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery))
                .toList();
          }

          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text("No products found",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWeb ? 4 : 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    String imageUrl = product['image_url'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '$BACKEND_BASE/$imageUrl';
    }

    String vendorName = product['vendor_shop_name'] ??
        product['vendorShopName'] ??
        product['shop_name'] ??
        "No Shop Name";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderNowScreen(
                currentUser: widget.user,
                product: product,
                productType: selectedCategory,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image, size: 50),
                    )
                  : Container(color: Colors.grey[200]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['title'] ?? "Gas Product",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("KSh ${product['price'] ?? '--'}",
                      style: TextStyle(
                          color: widget.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text("Vendor: $vendorName",
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text("Refill",
                        style: TextStyle(color: Colors.blue)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderNowScreen(
                            currentUser: widget.user,
                            product: product,
                            productType: selectedCategory,
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart,
                            color: Colors.green),
                        onPressed: () {
                          _addToCart(product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.orange),
                        onPressed: () => _shareProduct(product),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
