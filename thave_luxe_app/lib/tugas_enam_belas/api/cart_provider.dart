import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart'; // Import for addToCart method return type
import 'package:thave_luxe_app/tugas_enam_belas/models/cart_list_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/checkout_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/history_response.dart';

class CartProvider {
  // Helper to get user token
  Future<String?> _getUserToken() async {
    return await PreferenceHandler.getToken(); // Using your PreferenceHandler
  }

  // --- Helper for Authorized GET Requests ---
  Future<http.Response> _authorizedGet(String url) async {
    String? token = await _getUserToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    return response;
  }

  // --- Helper for Authorized POST Requests ---
  Future<http.Response> _authorizedPost(
    String url,
    Map<String, dynamic> body,
  ) async {
    String? token = await _getUserToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
    return response;
  }

  // --- Helper for Authorized DELETE Requests ---
  Future<http.Response> _authorizedDelete(String url) async {
    String? token = await _getUserToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.delete(
      Uri.parse(url),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    return response;
  }

  // GET List Keranjang
  Future<List<CartItem>> getCart() async {
    try {
      final response = await _authorizedGet(Endpoint.listCart);

      print('Cart List Response Status: ${response.statusCode}');
      print('Cart List Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final cartListResponse = cartListResponseFromJson(response.body);
        if (cartListResponse.data != null) {
          return cartListResponse.data!;
        }
        return []; // Return empty list if data is null
      } else {
        throw Exception(
          "Failed to load cart: ${response.statusCode} - ${response.body}",
        );
      }
    } on Exception catch (e) {
      throw Exception("Failed to load cart: $e");
    }
  }

  // --- NEWLY ADDED: Add/Update Item in Cart ---
  // This method typically handles adding a new item or updating the quantity of an existing item.
  Future<AddToCartResponse> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _authorizedPost(Endpoint.addToCart, {
        'product_id': productId,
        'quantity': quantity,
      });

      print('Add to Cart Response Status: ${response.statusCode}');
      print('Add to Cart Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 200 for update, 201 for create
        return addToCartResponseFromJson(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to add/update product in cart. Status Code: ${response.statusCode}",
        );
      }
    } on Exception catch (e) {
      throw Exception("Add/Update Cart Error: $e");
    }
  }

  // DELETE Produk dari Keranjang
  Future<bool> deleteFromCart({required int cartItemId}) async {
    try {
      // Corrected dynamic endpoint usage
      final response = await _authorizedDelete(
        Endpoint.deleteCartItem(cartItemId),
      );

      print('Delete from Cart Response Status: ${response.statusCode}');
      print('Delete from Cart Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content is common for successful DELETE
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to delete from cart: ${response.statusCode}",
        );
      }
    } on Exception catch (e) {
      throw Exception("Failed to delete from cart: $e");
    }
  }

  // POST Checkout
  Future<CheckoutResponse> checkout() async {
    try {
      final response = await _authorizedPost(
        Endpoint.checkout,
        {}, // Assuming empty body for checkout unless specified by API docs
      );

      print('Checkout Response Status: ${response.statusCode}');
      print('Checkout Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return checkoutResponseFromJson(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? "Failed to checkout: ${response.statusCode}",
        );
      }
    } on Exception catch (e) {
      throw Exception("Checkout Error: $e");
    }
  }

  // GET Riwayat Belanja (Transaction History)
  Future<HistoryResponse> getTransactionHistory() async {
    try {
      final response = await _authorizedGet(Endpoint.transactionHistory);

      print('Transaction History Response Status: ${response.statusCode}');
      print('Transaction History Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return historyResponseFromJson(response.body);
      } else {
        throw Exception(
          "Failed to load transaction history: ${response.statusCode} - ${response.body}",
        );
      }
    } on Exception catch (e) {
      throw Exception("Failed to load transaction history: $e");
    }
  }
}
