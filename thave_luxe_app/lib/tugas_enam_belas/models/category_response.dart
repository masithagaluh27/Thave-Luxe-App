import 'dart:convert';

// Function to parse JSON string into CategoryResponse object
CategoryResponse categoryResponseFromJson(String str) =>
    CategoryResponse.fromJson(json.decode(str));

// Function to convert CategoryResponse object to JSON string
String categoryResponseToJson(CategoryResponse data) =>
    json.encode(data.toJson());

class CategoryResponse {
  final String? message;
  final List<Category>? data; // List of Category objects
  final String? error; // For error messages

  CategoryResponse({this.message, this.data, this.error});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        message: json["message"],
        // Safely map data to a list of Category objects
        data:
            json["data"] == null
                ? []
                : List<Category>.from(
                  json["data"]!.map((x) => Category.fromJson(x)),
                ),
        error: json["error"], // Handle potential error field
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "error": error,
  };
}

class Category {
  final int? id;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({this.id, this.name, this.createdAt, this.updatedAt});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
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
