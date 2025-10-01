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

class PaymentMethod {
  final int paymentMethodId;
  final int userId;
  final String paymentType;
  final String? cardLastFour;
  final String? cardBrand;
  final int? expiryMonth;
  final int? expiryYear;
  final int? billingAddressId;
  final bool isDefault;

  PaymentMethod({
    required this.paymentMethodId,
    required this.userId,
    required this.paymentType,
    this.cardLastFour,
    this.cardBrand,
    this.expiryMonth,
    this.expiryYear,
    this.billingAddressId,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId: int.parse(json['payment_method_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      paymentType: json['payment_type'],
      cardLastFour: json['card_last_four'],
      cardBrand: json['card_brand'],
      expiryMonth: json['expiry_month'] != null
          ? int.parse(json['expiry_month'].toString())
          : null,
      expiryYear: json['expiry_year'] != null
          ? int.parse(json['expiry_year'].toString())
          : null,
      billingAddressId: json['billing_address_id'] != null
          ? int.parse(json['billing_address_id'].toString())
          : null,
      isDefault: json['is_default'].toString() == '1',
    );
  }

  String get displayName {
    if (paymentType == 'insurance') return 'Insurance';
    return '$cardBrand •••• $cardLastFour';
  }
}
