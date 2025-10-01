// ============================================
// PRODUCT DETAIL SCREEN
// Location: lib/screens/product_detail_screen.dart
// ============================================

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final int userId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  int _quantity = 1;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getProduct(widget.productId);

      if (response['success']) {
        setState(() {
          _product = Product.fromJson(response['data']);
        });
      } else {
        _showError(response['message'] ?? 'Failed to load product');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    setState(() => _addingToCart = true);

    try {
      final response = await ApiService.addToCart(
        userId: widget.userId,
        productId: widget.productId,
        quantity: _quantity,
      );

      if (response['success']) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Added to cart!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        _showError(response['message'] ?? 'Failed to add to cart');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => _addingToCart = false);
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
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
          ? const Center(child: Text('Product not found'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: _product!.imageUrl != null
                  ? Image.network(
                'http://10.0.2.2/pharmacy_backend/${_product!.imageUrl}',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.medical_services,
                    size: 100,
                  );
                },
              )
                  : const Icon(Icons.medical_services, size: 100),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    _product!.productName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Manufacturer
                  if (_product!.manufacturer != null)
                    Text(
                      _product!.manufacturer!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Price
                  Text(
                    '\$${_product!.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        _product!.stockQuantity > 0
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: _product!.stockQuantity > 0
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _product!.stockQuantity > 0
                            ? 'In Stock (${_product!.stockQuantity} available)'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: _product!.stockQuantity > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Prescription Required
                  if (_product!.requiresPrescription)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Prescription Required\nYou need to upload a valid prescription to purchase this product.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Details Section
                  if (_product!.activeIngredient != null ||
                      _product!.dosageForm != null ||
                      _product!.strength != null) ...[
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_product!.activeIngredient != null)
                      _buildDetailRow('Active Ingredient', _product!.activeIngredient!),

                    if (_product!.dosageForm != null)
                      _buildDetailRow('Dosage Form', _product!.dosageForm!),

                    if (_product!.strength != null)
                      _buildDetailRow('Strength', _product!.strength!),

                    const SizedBox(height: 24),
                  ],

                  // Description
                  if (_product!.description != null) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _product!.description!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quantity Selector
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _quantity < _product!.stockQuantity
                            ? () => setState(() => _quantity++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 32,
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _product != null && _product!.stockQuantity > 0
          ? SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _addingToCart ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _addingToCart
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Add to Cart - \$${(_product!.price * _quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}