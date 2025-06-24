import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/profile_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/error_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/auth_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/add_to_cart_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/car_list_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/checkout_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/history_response.dart';

class TokoOnlineService {
  // --- Authentication ---

  // Register Pembeli (Register User)
  Future<AuthResponse> registerUser({
    // Changed return type to AuthResponse
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.register),
      headers: {"Accept": "application/json"},
      body: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password, // As per your example
      },
    );

    print('Register Response Status: ${response.statusCode}');
    print('Register Response Body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final authResponse = authResponseFromJson(response.body);
      if (authResponse.data?.token != null) {
        await PreferenceHandler.setToken(authResponse.data!.token!);
      }
      return authResponse; // Return the AuthResponse object
    } else if (response.statusCode == 422) {
      // For validation errors, you might want to return ErrorResponse or throw an exception with its details
      final errorResponse = errorResponseFromJson(response.body);
      throw Exception(errorResponse.message ?? "Validation failed.");
    } else {
      throw Exception(
        "Failed to register user: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // Login
  Future<AuthResponse> loginUser({
    // Changed return type to AuthResponse
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.login),
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    print('Login Response Status: ${response.statusCode}');
    print('Login Response Body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final authResponse = authResponseFromJson(response.body);
      if (authResponse.data?.token != null) {
        await PreferenceHandler.setToken(authResponse.data!.token!);
      }
      return authResponse; // Return the AuthResponse object
    } else if (response.statusCode == 422) {
      // For validation errors, you might want to return ErrorResponse or throw an exception with its details
      final errorResponse = errorResponseFromJson(response.body);
      throw Exception(errorResponse.message ?? "Validation failed.");
    } else if (response.statusCode == 401) {
      throw Exception("Invalid credentials.");
    } else {
      throw Exception(
        "Failed to login: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // Get Profile
  Future<ProfileResponse> getProfile() async {
    // Changed return type to ProfileResponse
    String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.get(
      Uri.parse(Endpoint.profile),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print('Profile Response Status: ${response.statusCode}');
    print('Profile Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return profileResponseFromJson(
        response.body,
      ); // Return the ProfileResponse object
    } else if (response.statusCode == 401) {
      throw Exception(
        "Unauthorized: Your session has expired. Please log in again.",
      );
    } else {
      throw Exception(
        "Failed to load profile: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // Update Profile
  Future<bool> updateProfile(String name) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    final response = await http.put(
      Uri.parse(Endpoint.profileUpdate),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    print('Update Profile Response Status: ${response.statusCode}');
    print('Update Profile Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception(
        "Unauthorized: Your session has expired. Please log in again.",
      );
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ??
              "Failed to update profile: ${response.statusCode}",
        );
      } catch (e) {
        throw Exception(
          "Failed to update profile: ${response.statusCode} - ${response.body}",
        );
      }
    }
  }

  // --- Toko Online Specific API Calls ---

  // GET Daftar Produk
  Future<ProductResponse> getProducts() async {
    // Changed return type to ProductResponse
    final response = await http.get(
      Uri.parse(Endpoint.products),
      headers: {"Accept": "application/json"},
    );

    print('Products Response Status: ${response.statusCode}');
    print('Products Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return productResponseFromJson(
        response.body,
      ); // Return the ProductResponse object
    } else {
      throw Exception(
        "Failed to load products: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // POST Tambah ke Keranjang
  Future<AddToCartResponse> addToCart({
    // Changed return type to AddToCartResponse
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
      return addToCartResponseFromJson(
        response.body,
      ); // Return the AddToCartResponse object
    } else {
      throw Exception(
        "Failed to add to cart: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // GET List Keranjang
  Future<CartListResponse> getCart() async {
    // Changed return type to CartListResponse
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
      return cartListResponseFromJson(
        response.body,
      ); // Return the CartListResponse object
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
    // Changed return type to CheckoutResponse
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
      return checkoutResponseFromJson(
        response.body,
      ); // Return the CheckoutResponse object
    } else {
      throw Exception(
        "Failed to checkout: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // GET Riwayat Belanja (Transaction History)
  Future<HistoryResponse> getTransactionHistory() async {
    // Changed return type to HistoryResponse
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
      return historyResponseFromJson(
        response.body,
      ); // Return the HistoryResponse object
    } else {
      throw Exception(
        "Failed to load transaction history: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
