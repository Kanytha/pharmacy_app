import 'package:flutter/material.dart';
import '../models/payment_method.dart';
import '../services/api_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final int userId;

  const PaymentMethodsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _methods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getPaymentMethods(widget.userId);
      if (response['success']) {
        setState(() {
          _methods = (response['data'] as List)
              .map((json) => PaymentMethod.fromJson(json))
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to load methods')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddPaymentDialog() {
    final cardNumberController = TextEditingController();
    final cardBrandController = TextEditingController();
    final monthController = TextEditingController();
    final yearController = TextEditingController();
    String paymentType = 'credit_card';
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Payment Method'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: paymentType,
                  decoration: const InputDecoration(labelText: 'Payment Type'),
                  items: ['credit_card', 'debit_card', 'paypal']
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => paymentType = value!);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cardBrandController,
                  decoration: const InputDecoration(
                    labelText: 'Card Brand (e.g., Visa, Mastercard)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Last 4 Digits',
                    hintText: '1234',
                    counterText: "",
                  ),
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: monthController,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          hintText: '12',
                          counterText: "",
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          hintText: '2025',
                          counterText: "",
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as default'),
                  value: isDefault,
                  onChanged: (value) {
                    setDialogState(() => isDefault = value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (cardNumberController.text.isEmpty ||
                    cardBrandController.text.isEmpty ||
                    monthController.text.isEmpty ||
                    yearController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  final response = await ApiService.addPaymentMethod(
                    userId: widget.userId,
                    paymentType: paymentType,
                    cardLastFour: cardNumberController.text.trim(),
                    cardBrand: cardBrandController.text.trim(),
                    expiryMonth: int.parse(monthController.text.trim()),
                    expiryYear: int.parse(yearController.text.trim()),
                    isDefault: isDefault,
                  );

                  if (response['success']) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment method added!')),
                    );
                    _loadMethods();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'] ?? 'Failed')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePayment(int paymentMethodId) async {
    try {
      final response = await ApiService.deletePaymentMethod(paymentMethodId);
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method deleted')),
        );
        _loadMethods();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _methods.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No payment methods yet'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showAddPaymentDialog,
              child: const Text('Add Payment Method'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _methods.length,
        itemBuilder: (context, index) {
          final method = _methods[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.teal),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      method.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (method.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              subtitle: method.paymentType != 'insurance'
                  ? Text('Expires ${method.expiryMonth}/${method.expiryYear}')
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Payment Method'),
                      content: const Text('Are you sure you want to delete this method?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deletePayment(method.paymentMethodId);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
