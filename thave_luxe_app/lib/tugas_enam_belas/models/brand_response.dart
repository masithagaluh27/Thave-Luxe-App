// Path: lib/tugas_enam_belas/models/brand_response.dart

import 'dart:convert';

// Function to parse JSON string into BrandResponse object
BrandResponse brandResponseFromJson(String str) =>
    BrandResponse.fromJson(json.decode(str));

// Function to convert BrandResponse object to JSON string
String brandResponseToJson(BrandResponse data) => json.encode(data.toJson());

class BrandResponse {
  final String? message;
  final List<Brand>? data; // List of Brand objects
  final String? error; // For error messages

  BrandResponse({this.message, this.data, this.error});

  factory BrandResponse.fromJson(Map<String, dynamic> json) => BrandResponse(
    message: json["message"],
    data:
        json["data"] == null
            ? []
            : List<Brand>.from(json["data"]!.map((x) => Brand.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "error": error,
  };
}

class Brand {
  final int? id;
  final String? name;
  final String? imageUrl; // <--- Ensure this field exists and is nullable
  final String? description; // <--- Ensure this field exists and is nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Brand({
    this.id,
    this.name,
    this.imageUrl, // <--- Add to constructor
    this.description, // <--- Add to constructor
    this.createdAt,
    this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: json["id"],
    name: json["name"],
    imageUrl:
        json["image_url"], // <--- Ensure your API uses "image_url" or adjust accordingly
    description:
        json["description"], // <--- Ensure your API uses "description" or adjust accordingly
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image_url": imageUrl, // <--- Add to toJson
    "description": description, // <--- Add to toJson
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
