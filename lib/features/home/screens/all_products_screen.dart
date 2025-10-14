import 'package:ecommerce_app_fluterr_nodejs/common/widgets/loader.dart';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/product_card.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/home/services/home_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/product.dart';
import 'package:flutter/material.dart';

class AllProductsScreen extends StatefulWidget {
  static const String routeName = '/all-products';
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final HomeServices homeServices = HomeServices();
  String? selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  void fetchAllProducts() async {
    setState(() {
      _isLoading = true;
      _allProducts = [];
      _filteredProducts = [];
    });
    _allProducts = await homeServices.fetchAllProducts(
      context: context,
      category: null, // Fetch all products without category filter
    );
    print('Fetched ${_allProducts.length} products'); // Debug log
    _filterProducts();
    setState(() {
      _isLoading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = selectedCategory == null || product.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterProducts();
  }

  void _onCategorySelected(String? category) {
    setState(() {
      selectedCategory = category;
    });
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      controller: _searchController,
                      keyboardType: TextInputType.text,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        hintText: 'Search Products',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  _buildCategoryChip(null, 'All'),
                  ...GlobalVariables.categoryImages.map((category) {
                    return _buildCategoryChip(
                        category['title']!, category['title']!);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Loader()
          : _filteredProducts.isEmpty
              ? const Center(
                  child: Text('No Products Found!'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(product: product);
                  },
                ),
    );
  }

  Widget _buildCategoryChip(String? categoryKey, String label) {
    final isSelected = selectedCategory == categoryKey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _onCategorySelected(categoryKey);
          }
        },
        selectedColor: Color.fromRGBO(
          GlobalVariables.selectedNavBarColor.red,
          GlobalVariables.selectedNavBarColor.green,
          GlobalVariables.selectedNavBarColor.blue,
          0.8,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        backgroundColor: Colors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected
                ? GlobalVariables.selectedNavBarColor
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
