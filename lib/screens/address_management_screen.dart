import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class AddressManagementScreen extends StatefulWidget {
  final int userId;

  const AddressManagementScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAddresses(widget.userId);
      if (response['success']) {
        setState(() {
          _addresses = (response['data'] as List)
              .map((json) => Address.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddAddressDialog() {
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final postalController = TextEditingController();
    String addressType = 'home';
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: addressType,
                  decoration: const InputDecoration(labelText: 'Address Type'),
                  items: ['home', 'work', 'other']
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => addressType = value!);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: 'Street Address'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: postalController,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Set as default'),
                  value: isDefault,
                  onChanged: (value) {
                    setDialogState(() => isDefault = value!);
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
                if (streetController.text.isEmpty ||
                    cityController.text.isEmpty ||
                    stateController.text.isEmpty ||
                    postalController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final response = await ApiService.addAddress(
                  userId: widget.userId,
                  streetAddress: streetController.text.trim(),
                  city: cityController.text.trim(),
                  state: stateController.text.trim(),
                  postalCode: postalController.text.trim(),
                  addressType: addressType,
                  isDefault: isDefault,
                );

                if (response['success']) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address added!')),
                  );
                  _loadAddresses();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Failed')),
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

  Future<void> _deleteAddress(int addressId) async {
    final response = await ApiService.deleteAddress(addressId);
    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted')),
      );
      _loadAddresses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No addresses yet'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showAddAddressDialog,
              child: const Text('Add Address'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return Card(
            child: ListTile(
              title: Row(
                children: [
                  Text(address.addressType.toUpperCase()),
                  const SizedBox(width: 8),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              subtitle: Text(address.fullAddress),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Address'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteAddress(address.addressId);
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
        onPressed: _showAddAddressDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}