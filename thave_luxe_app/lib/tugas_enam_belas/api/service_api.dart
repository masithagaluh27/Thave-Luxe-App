import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ppkd_flutter_masitha/helper/preference.dart';
import 'package:ppkd_flutter_masitha/tugas_lima_belas/Models/profile_response.dart';
import 'package:ppkd_flutter_masitha/tugas_lima_belas/Models/register_error_response.dart';
import 'package:ppkd_flutter_masitha/tugas_lima_belas/Models/register_response.dart.dart';
import 'package:ppkd_flutter_masitha/tugas_lima_belas/endpoint.dart';

class UserService {
  //register
  Future<Map<String, dynamic>> registerUser({
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
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 201 || response.statusCode == 200) {
      print(registerResponseFromJson(response.body).toJson());
      return registerResponseFromJson(response.body).toJson();
    } else if (response.statusCode == 422) {
      return registerErrorResponseFromJson(response.body).toJson();
    } else {
      print("Failed to register user: ${response.statusCode}");
      throw Exception("Failed to register user: ${response.statusCode}");
    }
  }

  //login
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Endpoint.login),
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 201 || response.statusCode == 200) {
      print(registerResponseFromJson(response.body).toJson());
      return registerResponseFromJson(response.body).toJson();
    } else if (response.statusCode == 422) {
      return registerErrorResponseFromJson(response.body).toJson();
    } else {
      print("Failed to login: ${response.statusCode}");
      throw Exception("Failed to login user: ${response.statusCode}");
    }
  }

  //get profile

  Future<Map<String, dynamic>> getProfile() async {
    String? token = await PreferenceHandler.getToken();
    final response = await http.get(
      Uri.parse(Endpoint.profile),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print(response.body);
    if (response.statusCode == 200) {
      return profileUserModelFromJson(response.body).toJson();
    } else {
      throw Exception("Failed to load profile: ${response.statusCode}");
    }
  }

  //upate profile
  Future<bool> updateProfile(String name) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.put(
      Uri.parse(Endpoint.profileUpdate),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
