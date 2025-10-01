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


class User {
  final int userId;
  final String email;
  final String fullName;
  final String? phone;
  final String dateRegistered;
  final String? lastLogin;
  final String status;

  User({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phone,
    required this.dateRegistered,
    this.lastLogin,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return User(
      userId: parseInt(json['user_id']),
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      dateRegistered: json['date_registered']?.toString() ?? '',
      lastLogin: json['last_login']?.toString(),
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'date_registered': dateRegistered,
      'last_login': lastLogin,
      'status': status,
    };
  }
}