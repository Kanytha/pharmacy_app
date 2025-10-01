// Add at the very top after imports
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

class CartItem {
  final int cartId;
  final int userId;
  final int productId;
  final int quantity;
  final String addedAt;
  final int? prescriptionId;
  final String productName;
  final double price;
  final String? imageUrl;
  final int stockQuantity;
  final bool requiresPrescription;
  final double subtotal;

  CartItem({
    required this.cartId,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    this.prescriptionId,
    required this.productName,
    required this.price,
    this.imageUrl,
    required this.stockQuantity,
    required this.requiresPrescription,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: int.parse(json['cart_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      quantity: int.parse(json['quantity'].toString()),
      addedAt: json['added_at'],
      prescriptionId: json['prescription_id'] != null
          ? int.parse(json['prescription_id'].toString())
          : null,
      productName: json['product_name'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      stockQuantity: int.parse(json['stock_quantity'].toString()),
      requiresPrescription: json['requires_prescription'].toString() == '1',
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
