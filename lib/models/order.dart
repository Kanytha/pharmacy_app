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

class Order {
  final int orderId;
  final int userId;
  final String orderNumber;
  final String orderDate;
  final String orderStatus;
  final int shippingAddressId;
  final int paymentMethodId;
  final double subtotal;
  final double taxAmount;
  final double shippingFee;
  final double totalAmount;
  final String? trackingNumber;
  final String? shippedDate;
  final String? deliveredDate;
  final String? canceledDate;
  final String? cancellationReason;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final int? itemCount;

  Order({
    required this.orderId,
    required this.userId,
    required this.orderNumber,
    required this.orderDate,
    required this.orderStatus,
    required this.shippingAddressId,
    required this.paymentMethodId,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingFee,
    required this.totalAmount,
    this.trackingNumber,
    this.shippedDate,
    this.deliveredDate,
    this.canceledDate,
    this.cancellationReason,
    this.streetAddress,
    this.city,
    this.state,
    this.postalCode,
    this.itemCount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: _parseInt(json['order_id']),
      userId: _parseInt(json['user_id']),
      orderNumber: json['order_number']?.toString() ?? '',
      orderDate: json['order_date']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? '',
      shippingAddressId: _parseInt(json['shipping_address_id']),
      paymentMethodId: _parseInt(json['payment_method_id']),
      subtotal: _parseDouble(json['subtotal']),
      taxAmount: _parseDouble(json['tax_amount']),
      shippingFee: _parseDouble(json['shipping_fee']),
      totalAmount: _parseDouble(json['total_amount']),
      trackingNumber: json['tracking_number']?.toString(),
      shippedDate: json['shipped_date']?.toString(),
      deliveredDate: json['delivered_date']?.toString(),
      canceledDate: json['canceled_date']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      streetAddress: json['street_address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString(),
      itemCount: _parseInt(json['item_count']),
    );
  }
}