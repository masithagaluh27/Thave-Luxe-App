import 'dart:convert';

// Function to parse JSON string into ProfileResponse object
ProfileResponse profileResponseFromJson(String str) =>
    ProfileResponse.fromJson(json.decode(str));

// Function to convert ProfileResponse object to JSON string
String profileResponseToJson(ProfileResponse data) =>
    json.encode(data.toJson());

class ProfileResponse {
  final String? message;
  final AppUser? data; // Single AppUser object
  final String? error; // For error messages

  ProfileResponse({this.message, this.data, this.error});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        message: json["message"],
        data: json["data"] == null ? null : AppUser.fromJson(json["data"]),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
    "error": error,
  };
}

class AppUser {
  final int? id;
  final String? name;
  final String? email;
  final String? phone; // Assuming API provides phone
  final String? address; // Assuming API provides address
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"], // Map from JSON
    address: json["address"], // Map from JSON
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

  // Helper method to create a copy with new values (useful for local state updates)
  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
