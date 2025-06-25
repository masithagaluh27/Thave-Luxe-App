import 'dart:convert';

ProfileResponse profileResponseFromJson(String str) =>
    ProfileResponse.fromJson(json.decode(str));

String profileResponseToJson(ProfileResponse data) =>
    json.encode(data.toJson());

class ProfileResponse {
  String? message;
  User? user; // Changed from required to nullable

  ProfileResponse({this.message, this.user});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        message: json["message"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "user": user?.toJson()};
}

class User {
  int? id; // Made nullable
  String? name; // Made nullable, though usually required for profile
  String? email; // Made nullable, though usually required for profile
  dynamic
  emailVerifiedAt; // Made nullable (dynamic to handle null or date string)
  String? phone; // Made nullable
  String? address; // Made nullable
  DateTime? createdAt; // Made nullable
  DateTime? updatedAt; // Made nullable

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt:
        json["email_verified_at"], // This will now correctly handle null
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
    "email_verified_at": emailVerifiedAt,
    "phone": phone,
    "address": address,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
