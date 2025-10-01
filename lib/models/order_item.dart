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

class OrderItem {
  final int orderItemId;
  final int orderId;
  final int productId;
  final int? prescriptionId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? productName;
  final String? imageUrl;
  final String? manufacturer;

  OrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    this.prescriptionId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.productName,
    this.imageUrl,
    this.manufacturer,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: int.parse(json['order_item_id'].toString()),
      orderId: int.parse(json['order_id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      prescriptionId: json['prescription_id'] != null
          ? int.parse(json['prescription_id'].toString())
          : null,
      quantity: int.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      productName: json['product_name'],
      imageUrl: json['image_url'],
      manufacturer: json['manufacturer'],
    );
  }
}
