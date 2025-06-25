import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';

class ProductProvider {
  // GET Daftar Produk
  Future<ProductResponse> getProducts() async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.get(
      Uri.parse(Endpoint.products),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print('Products Response Status: ${response.statusCode}');
    print('Products Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return productResponseFromJson(response.body);
    } else if (response.statusCode == 401) {
      await PreferenceHandler.clearToken();
      throw Exception(
        "Unauthorized: Your session has expired. Please log in again to view products.",
      );
    } else {
      throw Exception(
        "Failed to load products: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // POST Tambah ke Keranjang
  Future<AddToCartResponse> addToCart({
    required int productId,
    required int quantity,
  }) async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.post(
      Uri.parse(Endpoint.addToCart), // Accessing the add to cart endpoint
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization":
            "Bearer $token", // Authorization header is already present here
      },
      body: jsonEncode({"product_id": productId, "quantity": quantity}),
    );

    print('Add to Cart Response Status: ${response.statusCode}');
    print('Add to Cart Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return addToCartResponseFromJson(response.body);
    } else if (response.statusCode == 401) {
      // Handle 401 specifically for add to cart as well
      await PreferenceHandler.clearToken(); // Clear expired token
      throw Exception(
        "Unauthorized: Your session has expired. Please log in again to add to cart.",
      );
    } else {
      throw Exception(
        "Failed to add to cart: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
