import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = "http://172.21.3.209/pharmacy_backend/api";
  // static const String baseUrl = "http://localhost/pharmacy_backend/api";
  static const String baseUrl = "http://10.0.2.2/pharmacy_backend/api";  // testing on mobile phone

  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return '$baseUrl/$imagePath';
  }

  // AUTHENTICATION APIs

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/get_profile.php?user_id=$userId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? fullName,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{'user_id': userId};
      if (fullName != null) body['full_name'] = fullName;
      if (phone != null) body['phone'] = phone;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/update_profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // PRODUCTS APIs

  /// Get all products with optional filters
  static Future<Map<String, dynamic>> getProducts({
    int? categoryId,
    String? search,
    bool? requiresRx,
  }) async {
    try {
      String url = '$baseUrl/products/get_all.php?';
      if (categoryId != null) url += 'category_id=$categoryId&';
      if (search != null) url += 'search=$search&';
      if (requiresRx != null) url += 'requires_rx=${requiresRx ? 1 : 0}&';

      final response = await http.get(Uri.parse(url));
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get single product details
  static Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/get_single.php?product_id=$productId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get all categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/get_categories.php'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Search products
  static Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search.php?q=$query'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // CART APIs

  /// Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    required int quantity,
    int? prescriptionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add_to_cart.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
          if (prescriptionId != null) 'prescription_id': prescriptionId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get user's cart
  static Future<Map<String, dynamic>> getCart(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart/get_cart.php?user_id=$userId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Update cart item quantity
  static Future<Map<String, dynamic>> updateCart({
    required int cartId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/update_cart.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cart_id': cartId,
          'quantity': quantity,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Remove item from cart
  static Future<Map<String, dynamic>> removeFromCart(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/remove_from_cart.php?cart_id=$cartId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

// ORDERS APIs

  /// Create new order
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int shippingAddressId,
    required int paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/create_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'shipping_address_id': shippingAddressId,
          'payment_method_id': paymentMethodId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get user's orders
  static Future<Map<String, dynamic>> getOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/get_orders.php?user_id=$userId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get order details
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/get_order_details.php?order_id=$orderId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Cancel order
  static Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/cancel_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'order_id': orderId,
          if (reason != null) 'reason': reason,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // ============================================
  // ADDRESSES APIs
  // ============================================

  /// Get user's addresses
  static Future<Map<String, dynamic>> getAddresses(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses/get_addresses.php?user_id=$userId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Add new address
  static Future<Map<String, dynamic>> addAddress({
    required int userId,
    required String streetAddress,
    required String city,
    required String state,
    required String postalCode,
    String? addressType,
    String? country,
    bool? isDefault,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addresses/add_address.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'street_address': streetAddress,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          if (addressType != null) 'address_type': addressType,
          if (country != null) 'country': country,
          if (isDefault != null) 'is_default': isDefault,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Delete address
  static Future<Map<String, dynamic>> deleteAddress(int addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/delete_address.php?address_id=$addressId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // ============================================
  // PAYMENT METHODS APIs
  // ============================================

  /// Get user's payment methods
  static Future<Map<String, dynamic>> getPaymentMethods(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/get_payment_methods.php?user_id=$userId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Add payment method
  static Future<Map<String, dynamic>> addPaymentMethod({
    required int userId,
    required String paymentType,
    required String cardLastFour,
    required String cardBrand,
    int? expiryMonth,
    int? expiryYear,
    int? billingAddressId,
    bool? isDefault,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/add_payment_method.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'payment_type': paymentType,
          'card_last_four': cardLastFour,
          'card_brand': cardBrand,
          if (expiryMonth != null) 'expiry_month': expiryMonth,
          if (expiryYear != null) 'expiry_year': expiryYear,
          if (billingAddressId != null) 'billing_address_id': billingAddressId,
          if (isDefault != null) 'is_default': isDefault,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Delete payment method
  static Future<Map<String, dynamic>> deletePaymentMethod(int paymentMethodId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/payments/delete_payment_method.php?payment_method_id=$paymentMethodId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // ============================================
  // PRESCRIPTIONS APIs
  // ============================================

  /// Upload prescription image
  static Future<Map<String, dynamic>> uploadPrescription({
    required int userId,
    required File imageFile,
    String? doctorName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/prescriptions/upload_prescription.php'),
      );

      request.fields['user_id'] = userId.toString();
      if (doctorName != null) request.fields['doctor_name'] = doctorName;

      request.files.add(
        await http.MultipartFile.fromPath(
          'prescription_image',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Upload error: ${e.toString()}',
      };
    }
  }

  /// Get user's prescriptions
  static Future<Map<String, dynamic>> getPrescriptions(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prescriptions/get_prescriptions.php?user_id=$userId'),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
}