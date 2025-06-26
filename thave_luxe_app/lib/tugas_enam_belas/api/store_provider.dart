import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart'; // Using your PreferenceHandler
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/brand_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/category_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'; // Using your Product model

class ApiProvider {
  // This helper will get the token using the PreferenceHandler
  // PreferenceHandler uses '_tokenKey = auth_token'
  Future<String?> _getUserToken() async {
    final token = await PreferenceHandler.getToken();
    print('ApiProvider: Retrieved token: $token'); // Add logging for debugging
    return token;
  }

  // --- Helper for Authorized GET Requests ---
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

  // --- Helper for Authorized POST Requests ---
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

  // --- Helper for Authorized PUT Requests ---
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

  // --- Helper for Authorized DELETE Requests ---
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

  // --- Fetch Products ---
  Future<ProductResponse> getProducts() async {
    try {
      // Products can typically be viewed without authentication, adjust if your API requires it.
      final response = await _authorizedGet(
        Endpoint.products,
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        return productResponseFromJson(response.body);
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
  Future<Product> addProduct({
    required String name,
    required int price,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final response = await _authorizedPost(
        Endpoint.products, // Assuming Endpoint.products is '/api/products'
        {
          'name': name,
          'price': price,
          'description': description,
          'image_url': imageUrl,
        },
        includeAuth: true, // Requires authentication
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        return Product.fromJson(
          jsonResponse['data'],
        ); // Assuming data is nested
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to add a product.",
        );
      } else {
        throw Exception(
          'Failed to add product: ${jsonResponse['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to add product: $e');
    }
  }

  /// Updates an existing product in the database. Requires admin privileges (auth token).
  Future<Product> updateProduct({
    required int id,
    required String name,
    required int price,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final response = await _authorizedPut(
        Endpoint.productDetail(
          id,
        ), // Assuming Endpoint.productDetail(id) is '/api/products/{id}'
        {
          'name': name,
          'price': price,
          'description': description,
          'image_url': imageUrl,
        },
        includeAuth: true, // Requires authentication
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Product.fromJson(
          jsonResponse['data'],
        ); // Assuming data is nested
      } else if (response.statusCode == 401) {
        await PreferenceHandler.clearToken();
        throw Exception(
          "Unauthorized: Your session has expired. Please log in again to update a product.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Product not found for update.");
      } else {
        throw Exception(
          'Failed to update product: ${jsonResponse['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to update product: $e');
    }
  }

  /// Deletes a product from the database. Requires admin privileges (auth token).
  Future<void> deleteProduct({required int id}) async {
    try {
      final response = await _authorizedDelete(
        Endpoint.products(
          id,
        ), // Assuming Endpoint.productDetail(id) is '/api/products/{id}'
        includeAuth: true, // Requires authentication
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
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

  // --- Add to Cart ---
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

  // --- Fetch Brands ---
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

  // --- Add Brand ---
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

  // --- Update Brand ---
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

  // --- Delete Brand ---
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

  // --- Fetch Categories ---
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

  // --- Add Category ---
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

  // --- Update Category ---
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

  // --- Delete Category ---
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
}
