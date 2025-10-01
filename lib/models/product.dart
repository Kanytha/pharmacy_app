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

class Product {
  final int productId;
  final int categoryId;
  final String productName;
  final String? description;
  final String? manufacturer;
  final String? activeIngredient;
  final String? dosageForm;
  final String? strength;
  final bool requiresPrescription;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final String status;
  final String? categoryName;
  final double? avgRating;
  final int? reviewCount;

  Product({
    required this.productId,
    required this.categoryId,
    required this.productName,
    this.description,
    this.manufacturer,
    this.activeIngredient,
    this.dosageForm,
    this.strength,
    required this.requiresPrescription,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    required this.status,
    this.categoryName,
    this.avgRating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: int.parse(json['product_id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      productName: json['product_name'],
      description: json['description'],
      manufacturer: json['manufacturer'],
      activeIngredient: json['active_ingredient'],
      dosageForm: json['dosage_form'],
      strength: json['strength'],
      requiresPrescription: json['requires_prescription'].toString() == '1',
      price: double.parse(json['price'].toString()),
      stockQuantity: int.parse(json['stock_quantity'].toString()),
      imageUrl: json['image_url'],
      status: json['status'],
      categoryName: json['category_name'],
      avgRating: json['avg_rating'] != null ? double.parse(json['avg_rating'].toString()) : null,
      reviewCount: json['review_count'] != null ? int.parse(json['review_count'].toString()) : null,
    );
  }
}