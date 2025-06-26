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
    // Safely map data to a list of Brand objects
    data:
        json["data"] == null
            ? []
            : List<Brand>.from(json["data"]!.map((x) => Brand.fromJson(x))),
    error: json["error"], // Handle potential error field
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Brand({this.id, this.name, this.createdAt, this.updatedAt});

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: json["id"],
    name: json["name"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
