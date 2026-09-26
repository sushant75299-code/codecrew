import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.235.89.111:8000';

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      final String? token = data['access_token'];

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login successful, but access token was not received.',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'access_token',
        token,
      );

      return;
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Login failed.',
      ),
    );
  }

  // ============================================================
  // GET TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('access_token');
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
  }

  // ============================================================
  // COMMON AUTH HEADERS
  // ============================================================

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ============================================================
  // GET PRODUCTS
  // ============================================================

  static Future<List<dynamic>> getProducts() async {
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
      headers: headers,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception(
        'Invalid product data received from server.',
      );
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Failed to load products.',
      ),
    );
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  static Future<void> addProduct({
    required String name,
    required String sku,
    required String category,
    required String unit,
    required double stock,
    required double reorderLevel,
  }) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'sku': sku,
        'category': category,
        'unit': unit,
        'stock': stock,
        'reorder_level': reorderLevel,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Failed to add product.',
      ),
    );
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  static Future<void> updateProduct({
    required int productId,
    required String name,
    required String sku,
    required String category,
    required String unit,
    required double stock,
    required double reorderLevel,
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/products/$productId'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'sku': sku,
        'category': category,
        'unit': unit,
        'stock': stock,
        'reorder_level': reorderLevel,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Failed to update product.',
      ),
    );
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  static Future<void> deleteProduct(
    int productId,
  ) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Failed to delete product.',
      ),
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Registration failed.',
      ),
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final url = Uri.parse(
      '$baseUrl/auth/forgot-password',
    ).replace(
      queryParameters: {
        'email': email,
      },
    );

    final response = await http.post(url);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Failed to generate OTP.',
      ),
    );
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse(
      '$baseUrl/auth/reset-password',
    ).replace(
      queryParameters: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      },
    );

    final response = await http.post(url);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      _getErrorMessage(
        response,
        'Password reset failed.',
      ),
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  static String _getErrorMessage(
    http.Response response,
    String defaultMessage,
  ) {
    try {
      final data = jsonDecode(response.body);

      if (data['detail'] != null) {
        final detail = data['detail'];

        if (detail is String) {
          return detail;
        }

        if (detail is List) {
          return detail
              .map(
                (item) => item['msg']?.toString() ?? 'Validation error',
              )
              .join(', ');
        }
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}

    if (response.statusCode == 401) {
      return 'Unauthorized. Please login again.';
    }

    if (response.statusCode == 404) {
      return 'Product not found.';
    }

    if (response.statusCode == 422) {
      return 'Invalid data. Please check your input.';
    }

    if (response.statusCode >= 500) {
      return 'Server error. Please try again later.';
    }

    return defaultMessage;
  }
}