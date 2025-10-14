# TODO: Modify All Products Screen for Local Search and Filter

## Steps to Complete

- [x] Add TextEditingController for search bar input.
- [x] Add state variables: List<Product> _allProducts, List<Product> _filteredProducts, String _searchQuery.
- [x] Modify initState to fetch all products initially and set _allProducts and _filteredProducts.
- [x] Implement _filterProducts() method to filter _allProducts based on _searchQuery and selectedCategory.
- [x] Update search bar to use onChanged instead of onFieldSubmitted, update _searchQuery and call _filterProducts (remove navigation to SearchScreen).
- [x] Modify category selection to update selectedCategory and call _filterProducts locally (no refetch).
- [x] Update GridView to use _filteredProducts instead of products.
- [x] Test the implementation by running the app and verifying search and category filtering work correctly.
- [x] Add navigation from "See All" button in DealOfDay widget to AllProductsScreen.
- [x] Add AllProductsScreen route to router.dart.
