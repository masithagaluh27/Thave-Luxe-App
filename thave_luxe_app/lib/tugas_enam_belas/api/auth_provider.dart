import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/endpoint.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/auth_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/error_response.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/profile_response.dart';

class AuthProvider {
  Future<AuthResponse> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.register),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final authResponse = authResponseFromJson(response.body);
      if (authResponse.data?.token != null) {
        await PreferenceHandler.setToken(authResponse.data!.token!);
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

  Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    final body = jsonEncode({"email": email, "password": password});
    final response = await http.post(url, headers: headers, body: body);
    print(response.body);
    if (response.statusCode == 200) {
      final authResponse = authResponseFromJson(response.body);
      final token = authResponse.data?.token;

      if (token != null) {
        await PreferenceHandler.setToken(token);
        print(response.body);
      }

      return authResponse;
    } else {
      try {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? "Login failed";
          throw Exception(message);
        } else {
          throw Exception("Unexpected error: ${response.body}");
        }
      } catch (e) {
        throw Exception(
          "Login failed. Could not parse response: ${e.toString()}",
        );
      }
    }
  }

  Future<ProfileResponse> getProfile() async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    Future<http.Response> _hit(String url) => http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    // Coba hit endpoint utama
    final res = await _hit(Endpoint.profile);

    // Jika 404, fallback ke /user
    if (res.statusCode == 404) {
      final fallback = '${Endpoint.profile}/user';
      final res2 = await _hit(fallback);
      if (res2.statusCode == 200) return profileResponseFromJson(res2.body);
    }

    if (res.statusCode == 200) {
      return profileResponseFromJson(res.body);
    } else if (res.statusCode == 401) {
      await PreferenceHandler.clearToken();
      throw Exception(
        "Unauthorized: Your session has expired. Please log in again.",
      );
    } else {
      throw Exception(
        "Failed to load profile: ${res.statusCode} - ${res.body}",
      );
    }
  }

  Future<void> logout() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token != null) {
        await http.post(
          Uri.parse(Endpoint.logout),
          headers: {
            "Accept": "application/json",
            "Authorization":
                token.startsWith("Bearer ") ? token : "Bearer $token",
          },
        );
      }
    } catch (_) {}

    // WAJIB clear data login setelah logout
    await PreferenceHandler.clearToken();
    await PreferenceHandler.clearUserDetails();
  }
}
