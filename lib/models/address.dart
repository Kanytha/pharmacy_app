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

class Address {
  final int addressId;
  final int userId;
  final String addressType;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  Address({
    required this.addressId,
    required this.userId,
    required this.addressType,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: int.parse(json['address_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      addressType: json['address_type'],
      streetAddress: json['street_address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      isDefault: json['is_default'].toString() == '1',
    );
  }

  String get fullAddress => '$streetAddress, $city, $state $postalCode, $country';
}