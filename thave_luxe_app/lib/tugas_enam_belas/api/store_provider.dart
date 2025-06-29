// File: thave_luxe_app/tugas_enam_belas/api/store_provider.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// ---------- 1. Tambah import baru di bagian atas ----------
import 'package:thave_luxe_app/tugas_enam_belas/models/add_product_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/edit_product_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/delete_product_response.dart';

import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/brand_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/cart_list_response.dart'; // Contains CartItemData
import 'package:thave_luxe_app/tugas_enam_belas/models/category_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/history_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/checkout_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/order_history_response.dart';

class ApiProvider {
  Future<String?> _getUserToken() async {
    final token = await PreferenceHandler.getToken();
    print('ApiProvider: Retrieved token: $token');
    return token;
  }

  Future<http.Response> _authorizedGet(
    String url, {
    bool includeAuth = true,
  }) async {
    final Map<String, String> headers = {'Accept': 'application/json'};
    if (includeAuth) {
      final token = await _getUserToken();
      if (token == null) {
        throw Exception("User not authenticated. Please log in.");
      }
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }

  Future<http.Response> _authorizedPost(
    String url,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final token = await _getUserToken();
      if (token == null) {
        throw Exception("User not authenticated. Please log in.");
      }
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> _authorizedPut(
    String url,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      final token = await _getUserToken();
      if (token == null) {
        throw Exception("User not authenticated. Please log in.");
      }
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> _authorizedDelete(
    String url, {
    bool includeAuth = true,
  }) async {
    final Map<String, String> headers = {'Accept': 'application/json'};
    if (includeAuth) {
      final token = await _getUserToken();
      if (token == null) {
        throw Exception("User not authenticated. Please log in.");
      }
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.delete(Uri.parse(url), headers: headers);
    return response;
  }

  // --- Fetch Products (modified to accept categoryId and simplified data handling) ---
  Future<ProductResponse> getProducts({int? categoryId}) async {
    try {
      String url = Endpoint.products;
      if (categoryId != null) {
        url =
            '$url?category_id=$categoryId'; // Append category_id as a query parameter
      }
      final response = await _authorizedGet(url, includeAuth: true);
      print(response.body);
      if (response.statusCode == 200) {
        final ProductResponse productResponse = productResponseFromJson(
          response.body,
        );
        return productResponse;
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again.",
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to load products. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Failed to load products: $e");
    }
  }

  /// Adds a new product to the database. Requires admin privileges (auth token).
  // ---------- 2. Ubah method addProduct ----------
  Future<AddProductResponse> addProduct({
    required String name,
    required int price,
    String? description,
    String? imageUrl,
    int? stock,
    int? brandId,
  }) async {
    try {
      final response = await _authorizedPost(Endpoint.products, {
        'name': name,
        'price': price,
        'description': description,
        'image_url': imageUrl,
        'stock': stock,
        'brand_id': brandId,
      }, includeAuth: true);

      if (response.statusCode == 201) {
        return addProductResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to add a product.",
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to add product: ${errorBody['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to add product: $e');
    }
  }

  /// Updates an existing product in the database. Requires admin privileges (auth token).
  // ---------- 3. Ubah method updateProduct ----------
  Future<EditProductResponse> updateProduct({
    required int id,
    required String name,
    required int price,
    String? description,
    String? imageUrl,
    int? stock,
    int? brandId,
  }) async {
    try {
      final response = await _authorizedPut(Endpoint.productDetail(id), {
        'name': name,
        'price': price,
        'description': description,
        'image_url': imageUrl,
        'stock': stock,
        'brand_id': brandId,
      }, includeAuth: true);

      if (response.statusCode == 200) {
        return editProductResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to update a product.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Product not found for update.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to update product: ${errorBody['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to update product: $e');
    }
  }

  /// Deletes a product from the database. Requires admin privileges (auth token).
  // ---------- 4. Ubah method deleteProduct ----------
  Future<DeleteProductResponse> deleteProduct({required int id}) async {
    try {
      final response = await _authorizedDelete(
        Endpoint.productDetail(id),
        includeAuth: true,
      );

      // 204 = no‑content; backend mungkin tidak kirim JSON apa‑apa
      if (response.statusCode == 204) {
        return DeleteProductResponse(message: "Product deleted", data: null);
      } else if (response.statusCode == 200) {
        return deleteProductResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to delete a product.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Product not found for deletion.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to delete product: ${errorBody['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to delete product: $e');
    }
  }

  // --- Cart operations (existing `getCart` method, confirmed correct name) ---
  Future<List<CartItem>> getCart() async {
    // Renamed from getCartItems for clarity and consistency
    final url = Uri.parse(Endpoint.getCart);
    try {
      final response = await _authorizedGet(url.toString());

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final CartListResponse cartResponse = CartListResponse.fromJson(
          jsonResponse,
        );
        return cartResponse.data ?? [];
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          'Failed to load cart: ${errorBody['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to get cart: $e');
    }
  }

  Future<AddToCartResponse> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _authorizedPost(Endpoint.addToCart, {
        'product_id': productId,
        'quantity': quantity,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return addToCartResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to add to cart.",
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to add product to cart. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Add to Cart Error: $e");
    }
  }

  Future<void> deleteCartItem({required int cartItemId}) async {
    try {
      final response = await _authorizedDelete(
        Endpoint.deleteCartItem(cartItemId),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        String errorMessage =
            'Failed to delete item from cart: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to connect to delete cart item: $e');
    }
  }

  Future<CheckoutResponse> checkout() async {
    try {
      final response = await _authorizedPost(Endpoint.checkout, {});
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckoutResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Checkout failed: ${jsonResponse['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to checkout: $e');
    }
  }

  Future<OrderHistoryResponse> getOrderHistory() async {
    try {
      final response = await _authorizedGet(Endpoint.transactionHistory);

      if (response.statusCode == 200) {
        return OrderHistoryResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to view order history.",
        );
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          'Failed to load order history: ${errorBody['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to get order history: $e');
    }
  }

  Future<BrandResponse> getBrands() async {
    try {
      final response = await _authorizedGet(Endpoint.brands);

      if (response.statusCode == 200) {
        return brandResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to view brands.",
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to load brands. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Failed to load brands: $e");
    }
  }

  Future<BrandResponse> addBrand({required String name}) async {
    try {
      final response = await _authorizedPost(Endpoint.brands, {'name': name});

      if (response.statusCode == 201) {
        return brandResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to add a brand.",
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to add brand. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Add Brand Error: $e");
    }
  }

  Future<BrandResponse> updateBrand({
    required int id,
    required String name,
  }) async {
    try {
      final response = await _authorizedPut(Endpoint.brandDetail(id), {
        'name': name,
      });

      if (response.statusCode == 200) {
        return brandResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to update a brand.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Brand not found for update.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to update brand. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Update Brand Error: $e");
    }
  }

  Future<void> deleteBrand({required int id}) async {
    try {
      final response = await _authorizedDelete(Endpoint.brandDetail(id));

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to delete a brand.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Brand not found for deletion.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to delete brand. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Delete Brand Error: $e");
    }
  }

  Future<CategoryResponse> getCategories() async {
    try {
      final response = await _authorizedGet(Endpoint.categories);

      if (response.statusCode == 200) {
        return categoryResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to view categories.",
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to load categories. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Failed to load categories: $e");
    }
  }

  Future<CategoryResponse> addCategory({required String name}) async {
    try {
      final response = await _authorizedPost(Endpoint.categories, {
        'name': name,
      });

      if (response.statusCode == 201) {
        return categoryResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to add a category.",
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to add category. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Add Category Error: $e");
    }
  }

  Future<CategoryResponse> updateCategory({
    required int id,
    required String name,
  }) async {
    try {
      final response = await _authorizedPut(Endpoint.categoryDetail(id), {
        'name': name,
      });

      if (response.statusCode == 200) {
        return categoryResponseFromJson(response.body);
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to update a category.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Category not found for update.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to update category. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Update Category Error: $e");
    }
  }

  Future<void> deleteCategory({required int id}) async {
    try {
      final response = await _authorizedDelete(Endpoint.categoryDetail(id));

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to delete a category.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Category not found for deletion.");
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to delete category. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Delete Category Error: $e");
    }
  }

  final http.Client client = http.Client();
  Future<HistoryResponse> getTransactionHistory() async {
    final token = await PreferenceHandler.getToken();

    final response = await client.get(
      Uri.parse(Endpoint.transactionHistory),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return historyResponseFromJson(response.body);
    } else {
      throw Exception("Failed to fetch transaction history");
    }
  }
}
