import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/car_list_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/checkout_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/history_response.dart';

class CartProvider {
  // GET List Keranjang
  Future<CartListResponse> getCart() async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.get(
      Uri.parse(Endpoint.listCart),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print('Cart List Response Status: ${response.statusCode}');
    print('Cart List Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return cartListResponseFromJson(response.body);
    } else {
      throw Exception(
        "Failed to load cart: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // DELETE Produk dari Keranjang
  Future<bool> deleteFromCart({required int cartItemId}) async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.delete(
      Uri.parse('${Endpoint.deleteFromCart}/$cartItemId'),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print('Delete from Cart Response Status: ${response.statusCode}');
    print('Delete from Cart Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        "Failed to delete from cart: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // POST Checkout
  Future<CheckoutResponse> checkout() async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.post(
      Uri.parse(Endpoint.checkout),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({}), // Assuming empty body for checkout unless specified
    );

    print('Checkout Response Status: ${response.statusCode}');
    print('Checkout Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return checkoutResponseFromJson(response.body);
    } else {
      throw Exception(
        "Failed to checkout: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // GET Riwayat Belanja (Transaction History)
  Future<HistoryResponse> getTransactionHistory() async {
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.get(
      Uri.parse(Endpoint.transactionHistory),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print('Transaction History Response Status: ${response.statusCode}');
    print('Transaction History Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return historyResponseFromJson(response.body);
    } else {
      throw Exception(
        "Failed to load transaction history: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
