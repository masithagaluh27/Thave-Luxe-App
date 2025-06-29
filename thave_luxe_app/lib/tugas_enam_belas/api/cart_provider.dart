import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/cart_list_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/checkout_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/history_response.dart';

class CartProvider {
  Future<String?> _getUserToken() async {
    return await PreferenceHandler.getToken();
  }

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

  Future<List<CartItem>> getCart() async {
    try {
      final response = await _authorizedGet(Endpoint.listCart);
      if (response.statusCode == 200) {
        final cartListResponse = cartListResponseFromJson(response.body);
        return cartListResponse.data ?? [];
      } else {
        throw Exception(
          "Failed to load cart: ${response.statusCode} - ${response.body}",
        );
      }
    } on Exception catch (e) {
      throw Exception("Failed to load cart: $e");
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

  Future<bool> deleteFromCart({required int cartItemId}) async {
    try {
      final response = await _authorizedDelete(
        Endpoint.deleteCartItem(cartItemId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
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

  Future<CheckoutResponse> checkout() async {
    try {
      final response = await _authorizedPost(Endpoint.checkout, {});
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

  Future<HistoryResponse> getTransactionHistory() async {
    try {
      final response = await _authorizedGet(Endpoint.transactionHistory);
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
