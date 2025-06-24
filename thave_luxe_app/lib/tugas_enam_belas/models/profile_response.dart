// lib/tugas_lima_belas/Models/profile_response.dart
import 'dart:convert';

ProfileResponse profileResponseFromJson(String str) =>
    ProfileResponse.fromJson(json.decode(str));
String profileResponseToJson(ProfileResponse data) =>
    json.encode(data.toJson());

class ProfileResponse {
  User? user;
  String? message; // Sometimes a message is also returned

  ProfileResponse({this.user, this.message});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {"user": user?.toJson(), "message": message};
}

class User {
  int? id;
  String? name;
  String? email;
  String? phone; // Assuming phone might be part of profile
  String? address; // Assuming address might be part of profile
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "address": address,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
