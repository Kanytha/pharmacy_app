// ============================================
// HOME SCREEN (Main Screen)
// Location: lib/screens/home_screen.dart
// ============================================

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'prescription_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final productsResponse = await ApiService.getProducts(
        categoryId: _selectedCategory,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      final categoriesResponse = await ApiService.getCategories();

      if (productsResponse['success']) {
        _products = (productsResponse['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }

      if (categoriesResponse['success']) {
        _categories = (categoriesResponse['data'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
      }
    } catch (e) {
      _showError('Error loading data: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? _buildAppBar() : null,
      body: _selectedIndex == 0 ? _buildHomeBody() : _buildOtherScreens(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Pharmacy App'),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(userId: widget.user.userId),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadData();
              },
            ),
          ),

          // Categories
          if (_categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = null);
                          _loadData();
                        },
                      ),
                    );
                  }

                  final category = _categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.categoryName),
                      selected: _selectedCategory == category.categoryId,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category.categoryId : null;
                        });
                        _loadData();
                      },
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // Products Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                productId: product.productId,
                userId: widget.user.userId,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 120,
              color: Colors.grey[200],
              child: Center(
                child: product.imageUrl != null
                    ? Image.network(
                  'http://10.0.2.2/pharmacy_backend/${product.imageUrl}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.medical_services, size: 48);
                  },
                )
                    : const Icon(Icons.medical_services, size: 48),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Manufacturer
                  if (product.manufacturer != null)
                    Text(
                      product.manufacturer!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 4),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  // Prescription Required Badge
                  if (product.requiresPrescription)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Rx Required',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherScreens() {
    switch (_selectedIndex) {
      case 1:
        return OrdersScreen(userId: widget.user.userId);
      case 2:
        return PrescriptionUploadScreen(userId: widget.user.userId);
      case 3:
        return ProfileScreen(user: widget.user);
      default:
        return Container();
    }
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.upload_file),
          label: 'Upload Rx',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}