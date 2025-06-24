// lib/tugas_lima_belas/Models/auth_response.dart
import 'dart:convert';

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));
String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  String? message;
  AuthData? data;

  AuthResponse({this.message, this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    message: json["message"],
    data: json["data"] == null ? null : AuthData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class AuthData {
  String? token;
  User? user;

  AuthData({this.token, this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    token: json["token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {"token": token, "user": user?.toJson()};
}

class User {
  int? id;
  String? name;
  String? email;
  DateTime? emailVerifiedAt; // Can be null
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt:
        json["email_verified_at"] == null
            ? null
            : DateTime.parse(json["email_verified_at"]),
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
