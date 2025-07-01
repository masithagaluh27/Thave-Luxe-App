import 'dart:convert';

import 'package:flutter/foundation.dart'; // Preferred for debugPrint in non-UI files
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/app_models.dart'
    as app_models; // Import all your models with prefix

class ApiProvider {
  static const String _baseUrl = 'https://apptoko.mobileprojp.com/api';

  Future<Map<String, String>> _getHeaders({bool useAuth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (useAuth) {
      final String? token = await PreferenceHandler.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('Headers: Using Authorization token.');
      } else {
        debugPrint(
          'Warning: No token found or token is empty for authenticated request.',
        );
        // Throw an exception immediately if a token is required but missing/empty
        throw Exception('Authentication token is missing. Please log in.');
      }
    } else {
      debugPrint('Headers: No authentication token required for this request.');
    }
    return headers;
  }

  Future<app_models.ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) fromJsonT,
  ) async {
    debugPrint('API Response URL: ${response.request?.url}');
    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    try {
      // Decode JSON even for error responses to get message/errors
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          'API Response Success: Status ${jsonResponse['status']}, Message: ${jsonResponse['message']}',
        );
        return app_models.ApiResponse<T>.fromJson(jsonResponse, fromJsonT);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        String errorMessage =
            jsonResponse['message']?.toString() ?? 'An error occurred.';
        if (jsonResponse['errors'] != null && jsonResponse['errors'] is Map) {
          final Map<String, dynamic> errors = jsonResponse['errors'];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '\n$key: ${value.join(', ')}';
            }
          });
        }
        debugPrint(
          'API Response Client Error (${response.statusCode}): $errorMessage',
        );
        throw Exception(
          errorMessage,
        ); // Throw to be caught by specific API call
      } else {
        String serverError =
            jsonResponse['message'] ?? 'Server error: ${response.statusCode}';
        debugPrint(
          'API Response Server Error (${response.statusCode}): $serverError',
        );
        throw Exception(serverError); // Throw to be caught by specific API call
      }
    } catch (e) {
      debugPrint('Error parsing or handling API response: $e');
      debugPrint('Raw response body: ${response.body}');
      // Re-throw as a more general exception if needed, or wrap in ApiResponse.error
      throw Exception('Failed to process API response: ${e.toString()}');
    }
  }

  Future<app_models.ApiResponse<void>> _handleResponseNoData(
    http.Response response,
  ) async {
    debugPrint('API Response URL: ${response.request?.url}');
    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    try {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint(
          'API Response Success (No Data): Status ${jsonResponse['status']}, Message: ${jsonResponse['message']}',
        );
        return app_models.ApiResponse<void>.fromJsonNoData(jsonResponse);
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
        debugPrint(
          'API Response Client Error (No Data, ${response.statusCode}): $errorMessage',
        );
        throw Exception(errorMessage);
      } else {
        String serverError =
            jsonResponse['message'] ?? 'Server error: ${response.statusCode}';
        debugPrint(
          'API Response Server Error (No Data, ${response.statusCode}): $serverError',
        );
        throw Exception(serverError);
      }
    } catch (e) {
      debugPrint('Error parsing or handling API response (no data): $e');
      debugPrint('Raw response body: ${response.body}');
      throw Exception('Failed to process API response: ${e.toString()}');
    }
  }

  // --- Auth API Calls ---
  Future<app_models.ApiResponse<app_models.AuthData>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    debugPrint('Registering user: $email');
    try {
      final headers = await _getHeaders(useAuth: false);
      final body = json.encode({
        'name': name,
        'email': email,
        'password': password,
      });
      debugPrint('Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);
      final apiResponse = await _handleResponse<app_models.AuthData>(
        response,
        (json) => app_models.AuthData.fromJson(json),
      );

      if (apiResponse.status == 'success' && apiResponse.data != null) {
        if (apiResponse.data!.token != null) {
          await PreferenceHandler.setToken(apiResponse.data!.token!);
        }
        if (apiResponse.data!.user != null) {
          await PreferenceHandler.setUserData(apiResponse.data!.user!);
        }
        debugPrint(
          'Registration successful. Data saved via PreferenceHandler.',
        );
      }
      return apiResponse;
    } catch (e) {
      debugPrint('Error in register: $e');
      return app_models.ApiResponse.error(
        error: 'Registration failed: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.AuthData>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');
    debugPrint('Attempting login for: $email');
    try {
      final headers = await _getHeaders(useAuth: false);
      final body = json.encode({'email': email, 'password': password});
      debugPrint('Request Body: $body');

      final response = await http.post(url, headers: headers, body: body);
      final apiResponse = await _handleResponse<app_models.AuthData>(
        response,
        (json) => app_models.AuthData.fromJson(json),
      );

      if (apiResponse.status == 'success' && apiResponse.data != null) {
        if (apiResponse.data!.token != null) {
          await PreferenceHandler.setToken(apiResponse.data!.token!);
        }
        if (apiResponse.data!.user != null) {
          await PreferenceHandler.setUserData(apiResponse.data!.user!);
        }
        debugPrint('Login successful. Data saved via PreferenceHandler.');
      }
      return apiResponse;
    } catch (e) {
      debugPrint('Error in login: $e');
      return app_models.ApiResponse.error(
        error: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<void>> logout() async {
    final url = Uri.parse('$_baseUrl/logout');
    debugPrint('Attempting logout...');
    try {
      final headers = await _getHeaders();
      final response = await http.post(url, headers: headers);
      final apiResponse = await _handleResponseNoData(response);
      debugPrint('API logout response received.');
      return apiResponse;
    } catch (e) {
      debugPrint('Error making API logout call: $e');
      return app_models.ApiResponse.error(
        error: 'Logout failed: ${e.toString()}',
      );
    } finally {
      // Always clear client-side data, regardless of server response or network error
      await PreferenceHandler.clearToken();
      await PreferenceHandler.clearUserDetails();
      debugPrint(
        'Client-side data cleared via PreferenceHandler in logout finally.',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.User>> getProfile() async {
    final url = Uri.parse('$_baseUrl/user');
    debugPrint('Fetching user profile...');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      return _handleResponse<app_models.User>(
        response,
        (json) => app_models.User.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error in getProfile: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to fetch profile: ${e.toString()}',
      );
    }
  }

  Future<bool> get isLoggedIn async {
    final String? token = await PreferenceHandler.getToken();
    final app_models.User? user = await PreferenceHandler.getUserData();
    return token != null && token.isNotEmpty && user != null;
  }

  Future<app_models.User?> get currentUser async {
    return await PreferenceHandler.getUserData();
  }

  // --- Product API Calls ---
  Future<app_models.ApiResponse<List<app_models.Product>>> getProducts({
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
    debugPrint('Fetching products from: $uri');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);
      return _handleResponse<List<app_models.Product>>(
        response,
        (json) =>
            (json as List)
                .map(
                  (i) => app_models.Product.fromJson(i as Map<String, dynamic>),
                )
                .toList(),
      );
    } catch (e) {
      debugPrint('Error in getProducts: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to fetch products: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.Product>> addProduct({
    required String name,
    required int price,
    required int stock,
    required int brandId,
    String? description,
    List<String>? images, // Base64 encoded images
    double? discount,
  }) async {
    final url = Uri.parse('$_baseUrl/products');
    debugPrint('Adding product: $name');
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'name': name,
        'price': price,
        'stock': stock,
        'brand_id': brandId,
        'description': description,
        'images': images, // Send as list of base64 strings
        'discount': discount,
      });
      debugPrint('Request Body: $body');
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse<app_models.Product>(
        response,
        (json) => app_models.Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error in addProduct: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to add product: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.Product>> updateProduct({
    required int productId,
    required String name,
    required int price,
    required int stock,
    required int brandId,
    String? description,
    List<String>? images, // Base64 encoded images or existing URLs
    double? discount,
  }) async {
    final url = Uri.parse('$_baseUrl/products/$productId');
    debugPrint('Updating product ID: $productId, Name: $name');
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'name': name,
        'price': price,
        'stock': stock,
        'brand_id': brandId,
        'description': description,
        'images': images,
        'discount': discount,
      });
      debugPrint('Request Body: $body');
      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse<app_models.Product>(
        response,
        (json) => app_models.Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error in updateProduct: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to update product: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<void>> deleteProduct({
    required int productId,
  }) async {
    final url = Uri.parse('$_baseUrl/products/$productId');
    debugPrint('Deleting product ID: $productId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      return _handleResponseNoData(response);
    } catch (e) {
      debugPrint('Error in deleteProduct: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to delete product: ${e.toString()}',
      );
    }
  }

  // --- Brand API Calls ---
  Future<app_models.ApiResponse<List<app_models.Brand>>> getBrands() async {
    final url = Uri.parse('$_baseUrl/brands'); // Correct URL
    debugPrint('Fetching brands from: $url');
    try {
      final headers = await _getHeaders(); // Get headers for authentication
      final response = await http.get(url, headers: headers); // Use http.get
      return _handleResponse<List<app_models.Brand>>(
        response,
        (json) =>
            (json as List)
                .map(
                  (i) => app_models.Brand.fromJson(i as Map<String, dynamic>),
                )
                .toList(),
      );
    } catch (e) {
      debugPrint('Error in getBrands: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to fetch brands: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.Brand>> addBrand({
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/brands');
    debugPrint('Adding brand: $name');
    try {
      final headers = await _getHeaders();
      final body = json.encode({'name': name});
      debugPrint('Request Body: $body');
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse<app_models.Brand>(
        response,
        (json) => app_models.Brand.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error in addBrand: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to add brand: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.Brand>> updateBrand({
    required int brandId,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/brands/$brandId');
    debugPrint('Updating brand ID: $brandId, Name: $name');
    try {
      final headers = await _getHeaders();
      final body = json.encode({'name': name});
      debugPrint('Request Body: $body');
      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse<app_models.Brand>(
        response,
        (json) => app_models.Brand.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error in updateBrand: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to update brand: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<void>> deleteBrand({
    required int brandId,
  }) async {
    final url = Uri.parse('$_baseUrl/brands/$brandId');
    debugPrint('Deleting brand ID: $brandId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      return _handleResponseNoData(response);
    } catch (e) {
      debugPrint('Error in deleteBrand: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to delete brand: ${e.toString()}',
      );
    }
  }

  // --- Category API Calls ---
  Future<app_models.ApiResponse<List<app_models.Category>>>
  getCategories() async {
    final url = Uri.parse('$_baseUrl/categories');
    debugPrint('Fetching categories from: $url');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      return _handleResponse<List<app_models.Category>>(
        response,
        (json) =>
            (json as List)
                .map(
                  (i) =>
                      app_models.Category.fromJson(i as Map<String, dynamic>),
                )
                .toList(),
      );
    } catch (e) {
      debugPrint('Error in getCategories: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to fetch categories: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.Category>> addCategory({
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/categories');
    debugPrint('Adding category: $name');
    try {
      final headers = await _getHeaders();
      final body = json.encode({'name': name});
      debugPrint('Request Body: $body');
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse<app_models.Category>(
        response,
        (json) => app_models.Category.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error in addCategory: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to add category: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.Category>> updateCategory({
    required int categoryId,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/categories/$categoryId');
    debugPrint('Updating category ID: $categoryId, Name: $name');
    try {
      final headers = await _getHeaders();
      final body = json.encode({'name': name});
      debugPrint('Request Body: $body');
      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse<app_models.Category>(
        response,
        (json) => app_models.Category.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error in updateCategory: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to update category: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<void>> deleteCategory({
    required int categoryId,
  }) async {
    final url = Uri.parse('$_baseUrl/categories/$categoryId');
    debugPrint('Deleting category ID: $categoryId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      return _handleResponseNoData(response);
    } catch (e) {
      debugPrint('Error in deleteCategory: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to delete category: ${e.toString()}',
      );
    }
  }

  // --- Cart API Calls ---
  Future<app_models.ApiResponse<List<app_models.CartItem>>> getCart() async {
    final url = Uri.parse('$_baseUrl/cart');
    debugPrint('Fetching cart items...');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      return _handleResponse<List<app_models.CartItem>>(
        response,
        (json) =>
            (json as List)
                .map(
                  (i) =>
                      app_models.CartItem.fromJson(i as Map<String, dynamic>),
                )
                .toList(),
      );
    } catch (e) {
      debugPrint('Error in getCart: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to fetch cart: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<app_models.CartItem>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final url = Uri.parse('$_baseUrl/cart');
    debugPrint('Adding to cart: Product ID $productId, Quantity $quantity');
    try {
      final headers = await _getHeaders();
      final body = json.encode({'product_id': productId, 'quantity': quantity});
      debugPrint('Request Body: $body');
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse<app_models.CartItem>(
        response,
        (json) => app_models.CartItem.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error in addToCart: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to add to cart: ${e.toString()}',
      );
    }
  }

  Future<app_models.ApiResponse<void>> deleteCartItem({
    required int cartItemId,
  }) async {
    final url = Uri.parse('$_baseUrl/cart/$cartItemId');
    debugPrint('Deleting cart item ID: $cartItemId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);
      return _handleResponseNoData(response);
    } catch (e) {
      debugPrint('Error in deleteCartItem: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to delete cart item: ${e.toString()}',
      );
    }
  }

  // --- Checkout API Calls ---
  Future<app_models.ApiResponse<app_models.CheckoutResponseData>>
  checkout() async {
    final url = Uri.parse('$_baseUrl/checkout');
    debugPrint('Proceeding to checkout...');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({}), // Empty body for a simple checkout trigger
      );
      return _handleResponse<app_models.CheckoutResponseData>(
        response,
        (json) => app_models.CheckoutResponseData.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error in checkout: $e');
      return app_models.ApiResponse.error(
        error: 'Checkout failed: ${e.toString()}',
      );
    }
  }

  // --- History API Calls ---
  Future<app_models.ApiResponse<List<app_models.History>>>
  getPurchaseHistory() async {
    final url = Uri.parse('$_baseUrl/history');
    debugPrint('Fetching purchase history...');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      return _handleResponse<List<app_models.History>>(
        response,
        (json) =>
            (json as List)
                .map(
                  (i) => app_models.History.fromJson(i as Map<String, dynamic>),
                )
                .toList(),
      );
    } catch (e) {
      debugPrint('Error in getPurchaseHistory: $e');
      return app_models.ApiResponse.error(
        error: 'Failed to fetch purchase history: ${e.toString()}',
      );
    }
  }
}
