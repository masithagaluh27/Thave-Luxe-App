// lib/tugas_lima_belas/Models/product_response.dart
import 'dart:convert';

ProductResponse productResponseFromJson(String str) =>
    ProductResponse.fromJson(json.decode(str));
String productResponseToJson(ProductResponse data) =>
    json.encode(data.toJson());

class ProductResponse {
  String? message;
  dynamic data; // Can be a single Product or a List<Product>

  ProductResponse({this.message, this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      ProductResponse(message: json["message"], data: json["data"]);

  Map<String, dynamic> toJson() => {"message": message, "data": data};
}

// Specific model for a single Product (used in POST Tambah Produk)
Product productFromJson(String str) => Product.fromJson(json.decode(str));
String productToJson(Product data) => json.encode(data.toJson());

class Product {
  int? id;
  String? name;
  String? description;
  int? price;
  int? stock;
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    // Safely parse 'id' to int?. Handles both int and string inputs.
    id:
        json["id"] == null
            ? null
            : (json["id"] is int
                ? json["id"]
                : int.tryParse(json["id"].toString())),
    name: json["name"],
    description: json["description"],
    // Safely parse 'price' to int?. Handles both int and string inputs.
    price:
        json["price"] == null
            ? null
            : (json["price"] is int
                ? json["price"]
                : int.tryParse(json["price"].toString())),
    // Safely parse 'stock' to int?. Handles both int and string inputs.
    stock:
        json["stock"] == null
            ? null
            : (json["stock"] is int
                ? json["stock"]
                : int.tryParse(json["stock"].toString())),
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
    "stock": stock,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

// Specific model for a list of Products (used in GET Daftar Produk)
List<Product> productListFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));
String productListToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// You would likely use ProductResponse with data being List<Product> for "GET Daftar Produk"
// Example usage:
// ProductResponse productListResponse = ProductResponse.fromJson(response.body);
// List<Product> products = List<Product>.from(productListResponse.data.map((x) => Product.fromJson(x)));
