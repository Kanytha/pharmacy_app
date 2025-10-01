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

class Category {
  final int categoryId;
  final String categoryName;
  final String? description;
  final int? parentCategoryId;
  final String? imageUrl;
  final int? productCount;

  Category({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.parentCategoryId,
    this.imageUrl,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: int.parse(json['category_id'].toString()),
      categoryName: json['category_name'],
      description: json['description'],
      parentCategoryId: json['parent_category_id'] != null
          ? int.parse(json['parent_category_id'].toString())
          : null,
      imageUrl: json['image_url'],
      productCount: json['product_count'] != null
          ? int.parse(json['product_count'].toString())
          : null,
    );
  }
}