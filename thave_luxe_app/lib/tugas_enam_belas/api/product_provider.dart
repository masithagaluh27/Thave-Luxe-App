import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';

class ProductProvider {
  // GET Daftar Produk
  Future<ProductResponse> getProducts() async {
    final response = await http.get(
      Uri.parse(Endpoint.products),
      headers: {"Accept": "application/json"},
    );

    print('Products Response Status: ${response.statusCode}');
    print('Products Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return productResponseFromJson(response.body);
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
      Uri.parse(Endpoint.addToCart),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"product_id": productId, "quantity": quantity}),
    );

    print('Add to Cart Response Status: ${response.statusCode}');
    print('Add to Cart Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return addToCartResponseFromJson(response.body);
    } else {
      throw Exception(
        "Failed to add to cart: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
