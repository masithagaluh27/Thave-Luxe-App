import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/auth_response.dart'; // Assuming this exists
import 'package:thave_luxe_app/tugas_enam_belas/models/error_response.dart'; // Assuming this exists
import 'package:thave_luxe_app/tugas_enam_belas/models/profile_response.dart'; // Assuming this exists

class AuthProvider {
  // Register User
  Future<AuthResponse> registerUser({
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
        "password_confirmation": password,
      },
    );

    print('Register Response Status: ${response.statusCode}');
    print('Register Response Body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final authResponse = authResponseFromJson(response.body);
      if (authResponse.data?.token != null) {
        await PreferenceHandler.setToken(
          authResponse.data!.token!,
        ); // Token saved here
      }
      return authResponse;
    } else if (response.statusCode == 422) {
      final errorResponse = errorResponseFromJson(response.body);
      throw Exception(errorResponse.message ?? "Validation failed.");
    } else {
      throw Exception(
        "Failed to register user: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // Login User
  Future<AuthResponse> loginUser({
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
        await PreferenceHandler.setToken(
          authResponse.data!.token!,
        ); // Token saved here
        // Consider saving user name and email to preferences here as well after successful login
        // if login_response returns them, similar to my previous `AuthProvider`
        // e.g., await PreferenceHandler.setUserName(authResponse.data!.user?.name ?? '');
        // e.g., await PreferenceHandler.setUserEmail(authResponse.data!.user?.email ?? '');
      }
      return authResponse;
    } else if (response.statusCode == 422) {
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
    String? token = await PreferenceHandler.getToken(); // Token retrieved here
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
      return profileResponseFromJson(response.body);
    } else if (response.statusCode == 401) {
      // Clear token if server explicitly says 401
      await PreferenceHandler.clearToken();
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
  Future<ProfileResponse> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    Map<String, dynamic> body = {'name': name};
    if (phone != null && phone.isNotEmpty) {
      body['phone'] = phone;
    }
    if (address != null && address.isNotEmpty) {
      body['address'] = address;
    }

    final response = await http.put(
      Uri.parse(Endpoint.profileUpdate),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('Update Profile Response Status: ${response.statusCode}');
    print('Update Profile Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return profileResponseFromJson(response.body);
    } else if (response.statusCode == 401) {
      await PreferenceHandler.clearToken();
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

  // Add a logout method to clear the token locally
  Future<void> logout() async {
    // Optionally call server logout endpoint here if your API has one
    // try {
    //   final token = await PreferenceHandler.getToken();
    //   if (token != null) {
    //     await http.post(Uri.parse(Endpoint.logout), headers: {'Authorization': 'Bearer $token'});
    //   }
    // } catch (e) {
    //   print('Server logout failed: $e');
    //   // Continue with local clear even if server logout fails
    // }
    await PreferenceHandler.clearToken(); // Always clear local token
    await PreferenceHandler.clearUserDetails(); // Clear other user details
    print("User logged out locally.");
  }
}
