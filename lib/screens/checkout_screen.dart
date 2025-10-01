// ============================================
// CHECKOUT SCREEN
// Location: lib/screens/checkout_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:pharmacy_application/screens/payment_methods_screen.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../services/api_service.dart';
import 'address_management_screen.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int userId;
  final List<CartItem> cartItems;
  final double total;

  const CheckoutScreen({
    Key? key,
    required this.userId,
    required this.cartItems,
    required this.total,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Address> _addresses = [];
  List<PaymentMethod> _paymentMethods = [];
  Address? _selectedAddress;
  PaymentMethod? _selectedPayment;
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final addressResponse = await ApiService.getAddresses(widget.userId);
      final paymentResponse = await ApiService.getPaymentMethods(widget.userId);

      if (addressResponse['success']) {
        _addresses = (addressResponse['data'] as List)
            .map((json) => Address.fromJson(json))
            .toList();

        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.firstWhere(
                (addr) => addr.isDefault,
            orElse: () => _addresses.first,
          );
        }
      }

      if (paymentResponse['success']) {
        _paymentMethods = (paymentResponse['data'] as List)
            .map((json) => PaymentMethod.fromJson(json))
            .toList();

        if (_paymentMethods.isNotEmpty) {
          _selectedPayment = _paymentMethods.firstWhere(
                (pm) => pm.isDefault,
            orElse: () => _paymentMethods.first,
          );
        }
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      _showError('Please select a delivery address');
      return;
    }

    if (_selectedPayment == null) {
      _showError('Please select a payment method');
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final response = await ApiService.createOrder(
        userId: widget.userId,
        shippingAddressId: _selectedAddress!.addressId,
        paymentMethodId: _selectedPayment!.paymentMethodId,
      );

      if (response['success']) {
        if (!mounted) return;

        final orderData = response['data'];
        final orderId = orderData['order_id'] is int
            ? orderData['order_id']
            : int.parse(orderData['order_id'].toString());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              orderNumber: orderData['order_number'].toString(),
              orderId: orderId,
              userId: widget.userId,
            ),
          ),
        );
      }
      else {
        _showError(response['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      setState(() => _isPlacingOrder = false);
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
        title: const Text('Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
            _buildSectionHeader('Delivery Address'),
            _addresses.isEmpty
                ? _buildEmptySection(
              'No addresses found',
              'Add an address in your profile',
            )
                : _buildAddressSelector(),

            const Divider(height: 32),

            // Payment Method Section
            _buildSectionHeader('Payment Method'),
            _paymentMethods.isEmpty
                ? _buildEmptySection(
              'No payment methods found',
              'Add a payment method in your profile',
            )
                : _buildPaymentSelector(),

            const Divider(height: 32),

            // Order Summary
            _buildSectionHeader('Order Summary'),
            _buildOrderSummary(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptySection(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSelector() {
    if (_addresses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('No addresses found'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to add address
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressManagementScreen(userId: widget.userId),
                      ),
                    );
                    _loadData(); // Reload after returning
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Address'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: Text(_selectedAddress?.addressType.toUpperCase() ?? ''),
              subtitle: Text(_selectedAddress?.fullAddress ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAddressSelection();
              },
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressManagementScreen(userId: widget.userId),
                ),
              );
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  void _showAddressSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Address'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              final address = _addresses[index];
              final isSelected = _selectedAddress?.addressId == address.addressId;
              return RadioListTile<int>(
                value: address.addressId,
                groupValue: _selectedAddress?.addressId,
                onChanged: (value) {
                  setState(() => _selectedAddress = address);
                  Navigator.pop(context);
                },
                title: Text(address.addressType.toUpperCase()),
                subtitle: Text(address.fullAddress),
                selected: isSelected,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    if (_paymentMethods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('No payment methods found'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentMethodsScreen(userId: widget.userId),
                      ),
                    );
                    _loadData();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payment Method'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: Text(_selectedPayment?.displayName ?? ''),
              subtitle: _selectedPayment?.paymentType != 'insurance'
                  ? Text('Expires ${_selectedPayment?.expiryMonth}/${_selectedPayment?.expiryYear}')
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showPaymentSelection();
              },
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentMethodsScreen(userId: widget.userId),
                ),
              );
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Payment Method'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Payment Method'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final payment = _paymentMethods[index];
              final isSelected = _selectedPayment?.paymentMethodId == payment.paymentMethodId;
              return RadioListTile<int>(
                value: payment.paymentMethodId,
                groupValue: _selectedPayment?.paymentMethodId,
                onChanged: (value) {
                  setState(() => _selectedPayment = payment);
                  Navigator.pop(context);
                },
                title: Text(payment.displayName),
                subtitle: payment.paymentType != 'insurance'
                    ? Text('Expires ${payment.expiryMonth}/${payment.expiryYear}')
                    : null,
                selected: isSelected,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = widget.total;
    final tax = subtotal * 0.08; // 8% tax
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final total = subtotal + tax + shipping;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...widget.cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.productName} x${item.quantity}'),
                    ),
                    Text('\$${item.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(height: 24),
              _buildSummaryRow('Subtotal', subtotal),
              _buildSummaryRow('Tax (8%)', tax),
              _buildSummaryRow('Shipping', shipping),
              const Divider(height: 24),
              _buildSummaryRow(
                'Total',
                total,
                isBold: true,
                isLarge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      String label,
      double amount, {
        bool isBold = false,
        bool isLarge = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 18 : 14,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 18 : 14,
              color: isBold ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final subtotal = widget.total;
    final tax = subtotal * 0.08;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final total = subtotal + tax + shipping;

    return Container(
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}