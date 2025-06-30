import 'dart:convert';
import 'package:flutter/material.dart'; // For debugPrint
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart'; // Ensure this path is correct
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'; // Your app models

class ApiProvider {
  static const String _baseUrl = 'https://apptoko.mobileprojp.com/api';

  Future<Map<String, String>> _getHeaders({bool useAuth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (useAuth) {
      final String? token =
          await PreferenceHandler.getToken(); // Get token using your method
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        debugPrint('Warning: No token found for authenticated request.');
        throw Exception('Authentication token is missing. Please log in.');
      }
    }
    return headers;
  }

  // ... (_handleResponse and _handleResponseNoData remain the same) ...
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) fromJsonT,
  ) async {
    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    try {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.fromJson(jsonResponse, fromJsonT);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        String errorMessage =
            jsonResponse['message'] as String? ?? 'An error occurred.';
        if (jsonResponse['errors'] != null && jsonResponse['errors'] is Map) {
          final Map<String, dynamic> errors = jsonResponse['errors'];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '\n$key: ${value.join(', ')}';
            }
          });
        }
        throw Exception(errorMessage);
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error parsing API response: $e');
      throw Exception('Failed to process API response: ${e.toString()}');
    }
  }

  Future<ApiResponse<void>> _handleResponseNoData(
    http.Response response,
  ) async {
    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    try {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<void>.fromJsonNoData(jsonResponse);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        String errorMessage =
            jsonResponse['message'] as String? ?? 'An error occurred.';
        if (jsonResponse['errors'] != null && jsonResponse['errors'] is Map) {
          final Map<String, dynamic> errors = jsonResponse['errors'];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '\n$key: ${value.join(', ')}';
            }
          });
        }
        throw Exception(errorMessage);
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error parsing API response (no data): $e');
      throw Exception('Failed to process API response: ${e.toString()}');
    }
  }

  // -----------------------------------------------------------------------------
  // Auth API Calls
  // -----------------------------------------------------------------------------

  Future<ApiResponse<AuthData>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    final headers = await _getHeaders(useAuth: false);
    final body = json.encode({
      'name': name,
      'email': email,
      'password': password,
    });

    final response = await http.post(url, headers: headers, body: body);
    final apiResponse = await _handleResponse<AuthData>(
      response,
      (json) => AuthData.fromJson(json),
    );

    // After successful registration (if it also logs in and returns a token/user)
    if (apiResponse.status == 'success' && apiResponse.data != null) {
      if (apiResponse.data!.token != null) {
        await PreferenceHandler.setToken(
          apiResponse.data!.token!,
        ); // Use your setToken
      }
      if (apiResponse.data!.user != null) {
        await PreferenceHandler.setUserData(
          apiResponse.data!.user!,
        ); // Use your setUserData
      }
      debugPrint('Registration successful. Data saved via PreferenceHandler.');
    }
    return apiResponse;
  }

  Future<ApiResponse<AuthData>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');
    final headers = await _getHeaders(useAuth: false);
    final body = json.encode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);
    final apiResponse = await _handleResponse<AuthData>(
      response,
      (json) => AuthData.fromJson(json),
    );

    // After successful login, save the token and user data
    if (apiResponse.status == 'success' && apiResponse.data != null) {
      if (apiResponse.data!.token != null) {
        await PreferenceHandler.setToken(
          apiResponse.data!.token!,
        ); // Use your setToken
      }
      if (apiResponse.data!.user != null) {
        await PreferenceHandler.setUserData(
          apiResponse.data!.user!,
        ); // Use your setUserData
      }
      debugPrint('Login successful. Data saved via PreferenceHandler.');
    }
    return apiResponse;
  }

  Future<ApiResponse<void>> logout() async {
    final url = Uri.parse('$_baseUrl/logout');
    // Try to send token for server-side invalidation
    final headers = await _getHeaders();
    final response = await http.post(url, headers: headers);
    final apiResponse = await _handleResponseNoData(response);

    // Always clear client-side data, regardless of server response
    await PreferenceHandler.clearToken(); // Use your clearToken
    await PreferenceHandler.clearUserDetails(); // Use your clearUserDetails
    // Or if you prefer clearing everything: await PreferenceHandler.clearAllPreferences();
    debugPrint(
      'Logout processed. Client-side data cleared via PreferenceHandler.',
    );
    return apiResponse;
  }

  Future<ApiResponse<User>> getProfile() async {
    final url = Uri.parse('$_baseUrl/user');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    return _handleResponse<User>(response, (json) => User.fromJson(json));
  }

  // Convenience getter to check login status
  Future<bool> get isLoggedIn async {
    // Check if both a token and user data exist
    final String? token = await PreferenceHandler.getToken();
    final User? user = await PreferenceHandler.getUserData();
    return token != null && token.isNotEmpty && user != null;
  }

  // Convenience getter to get current user data
  Future<User?> get currentUser async {
    return await PreferenceHandler.getUserData();
  }

  // ... (rest of your API calls remain the same) ...
  Future<ApiResponse<List<Product>>> getProducts({
    int? categoryId,
    int? brandId,
  }) async {
    final Map<String, String> queryParams = {};
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }
    if (brandId != null) {
      queryParams['brand_id'] = brandId.toString();
    }

    final uri = Uri.parse(
      '$_baseUrl/products',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    return _handleResponse<List<Product>>(
      response,
      (json) =>
          (json as List)
              .map((i) => Product.fromJson(i as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<ApiResponse<Product>> addProduct({
    required String name,
    required String description,
    required int price,
    required int stock,
    int? categoryId,
    int? brandId,
    double? discount,
    List<String>? images,
  }) async {
    final url = Uri.parse('$_baseUrl/products');
    final headers = await _getHeaders();
    final body = json.encode({
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'brand_id': brandId,
      'discount': discount,
      'images': images,
    });

    final response = await http.post(url, headers: headers, body: body);
    return _handleResponse<Product>(response, (json) => Product.fromJson(json));
  }

  Future<ApiResponse<Product>> updateProduct({
    required int productId,
    required String name,
    required String description,
    required int price,
    required int stock,
    int? categoryId,
    int? brandId,
    double? discount,
    List<String>? images,
  }) async {
    final url = Uri.parse('$_baseUrl/products/$productId');
    final headers = await _getHeaders();
    final body = json.encode({
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'brand_id': brandId,
      'discount': discount,
      'images': images,
    });

    final response = await http.put(url, headers: headers, body: body);
    return _handleResponse<Product>(response, (json) => Product.fromJson(json));
  }

  Future<ApiResponse<void>> deleteProduct({required int productId}) async {
    final url = Uri.parse('$_baseUrl/products/$productId');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    return _handleResponseNoData(response);
  }

  // -----------------------------------------------------------------------------
  // Brand API Calls
  // -----------------------------------------------------------------------------

  Future<ApiResponse<List<Brand>>> getBrands() async {
    final url = Uri.parse('$_baseUrl/brands'); // Correct URL
    try {
      final headers = await _getHeaders(); // Get headers for authentication
      final response = await http.get(url, headers: headers); // Use http.get
      return _handleResponse<List<Brand>>(
        response,
        (json) =>
            (json as List)
                .map((i) => Brand.fromJson(i as Map<String, dynamic>))
                .toList(),
      );
    } catch (e) {
      // Catch and rethrow, or wrap in ApiResponse.error
      // Based on your existing _handleResponse, throwing an Exception is consistent
      debugPrint('Error in getBrands: $e');
      throw Exception('Failed to fetch brands: ${e.toString()}');
    }
  }

  Future<ApiResponse<Brand>> addBrand({required String name}) async {
    final url = Uri.parse('$_baseUrl/brands');
    final headers = await _getHeaders();
    final body = json.encode({'name': name});
    final response = await http.post(url, headers: headers, body: body);
    return _handleResponse<Brand>(response, (json) => Brand.fromJson(json));
  }

  Future<ApiResponse<Brand>> updateBrand({
    required int brandId,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/brands/$brandId');
    final headers = await _getHeaders();
    final body = json.encode({'name': name});
    final response = await http.put(url, headers: headers, body: body);
    return _handleResponse<Brand>(response, (json) => Brand.fromJson(json));
  }

  Future<ApiResponse<void>> deleteBrand({required int brandId}) async {
    final url = Uri.parse('$_baseUrl/brands/$brandId');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    return _handleResponseNoData(response);
  }

  // -----------------------------------------------------------------------------
  // Category API Calls
  // -----------------------------------------------------------------------------

  Future<ApiResponse<List<Category>>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    return _handleResponse<List<Category>>(
      response,
      (json) =>
          (json as List)
              .map((i) => Category.fromJson(i as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<ApiResponse<Category>> addCategory({required String name}) async {
    final url = Uri.parse('$_baseUrl/categories');
    final headers = await _getHeaders();
    final body = json.encode({'name': name});
    final response = await http.post(url, headers: headers, body: body);
    return _handleResponse<Category>(
      response,
      (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> updateCategory({
    required int categoryId,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/categories/$categoryId');
    final headers = await _getHeaders();
    final body = json.encode({'name': name});
    final response = await http.put(url, headers: headers, body: body);
    return _handleResponse<Category>(
      response,
      (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteCategory({required int categoryId}) async {
    final url = Uri.parse('$_baseUrl/categories/$categoryId');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    return _handleResponseNoData(response);
  }

  // -----------------------------------------------------------------------------
  // Cart API Calls
  // -----------------------------------------------------------------------------

  Future<ApiResponse<List<CartItem>>> getCart() async {
    final url = Uri.parse('$_baseUrl/cart');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    return _handleResponse<List<CartItem>>(
      response,
      (json) =>
          (json as List)
              .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
              .toList(),
    );
  }

  Future<ApiResponse<CartItem>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final url = Uri.parse('$_baseUrl/cart');
    final headers = await _getHeaders();
    final body = json.encode({'product_id': productId, 'quantity': quantity});
    final response = await http.post(url, headers: headers, body: body);
    return _handleResponse<CartItem>(
      response,
      (json) => CartItem.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteCartItem({required int cartItemId}) async {
    final url = Uri.parse('$_baseUrl/cart/$cartItemId');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    return _handleResponseNoData(response);
  }

  // -----------------------------------------------------------------------------
  // Checkout API Calls
  // -----------------------------------------------------------------------------

  Future<ApiResponse<CheckoutResponseData>> checkout() async {
    final url = Uri.parse('$_baseUrl/checkout');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({}),
    );
    return _handleResponse<CheckoutResponseData>(
      response,
      (json) => CheckoutResponseData.fromJson(json),
    );
  }

  // -----------------------------------------------------------------------------
  // History API Calls (Menggunakan model History dari app_models.dart)
  // -----------------------------------------------------------------------------

  Future<ApiResponse<List<History>>> getPurchaseHistory() async {
    final url = Uri.parse('$_baseUrl/history');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    return _handleResponse<List<History>>(
      response,
      (json) =>
          (json as List)
              .map((i) => History.fromJson(i as Map<String, dynamic>))
              .toList(),
    );
  }
}
