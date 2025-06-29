// Path: lib/tugas_enam_belas/models/produk_response.dart

import 'dart:convert';

// --- ProductResponse related functions and class ---
ProductResponse productResponseFromJson(String str) =>
    ProductResponse.fromJson(json.decode(str));

String productResponseToJson(ProductResponse data) =>
    json.encode(data.toJson());

class ProductResponse {
  String? message;
  List<Product>? data;
  dynamic meta;

  ProductResponse({this.message, this.data, this.meta});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      message: json["message"],
      // Safely parse 'data' which can be a List or a single object
      data:
          json["data"] is List
              ? List<Product>.from(json["data"].map((x) => Product.fromJson(x)))
              : (json["data"] != null && json["data"] is Map<String, dynamic>
                  ? [
                    Product.fromJson(json["data"]),
                  ] // Wrap single product in a list
                  : []), // Return empty list if data is null or not a valid type
      meta: json["meta"],
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "meta": meta,
  };
}

// --- Product related functions and class ---
Product productFromJson(String str) => Product.fromJson(json.decode(str));
String productToJson(Product data) => json.encode(data.toJson());

class Product {
  int? id;
  String? name;
  String? description;
  int? price;
  int? discount;
  int? stock;
  String? imageUrl;
  int? brandId;
  Brand? brand; // The nested Brand object
  int? categoryId;
  ProductCategory? category; // The nested ProductCategory object
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.discount,
    this.stock,
    this.imageUrl,
    this.brandId,
    this.brand,
    this.categoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id:
        json["id"] == null
            ? null
            : (json["id"] is int
                ? json["id"]
                : int.tryParse(json["id"].toString())),
    name: json["name"],
    description: json["description"],
    price:
        json["price"] == null
            ? null
            : (json["price"] is int
                ? json["price"]
                : int.tryParse(json["price"].toString())),
    discount:
        json["discount"] == null
            ? null
            : (json["discount"] is int
                ? json["discount"]
                : int.tryParse(json["discount"].toString())),
    stock:
        json["stock"] == null
            ? null
            : (json["stock"] is int
                ? json["stock"]
                : int.tryParse(json["stock"].toString())),
    imageUrl: json["image_url"],
    brandId:
        json["brand_id"] == null
            ? null
            : (json["brand_id"] is int
                ? json["brand_id"]
                : int.tryParse(json["brand_id"].toString())),
    // --- IMPORTANT CHANGE HERE FOR BRAND ---
    brand:
        json["brand"] is Map<String, dynamic>
            ? Brand.fromJson(json["brand"])
            : null, // Only parse if it's actually a Map, otherwise set to null
    // --- IMPORTANT CHANGE HERE FOR CATEGORY ---
    categoryId:
        json["category_id"] == null
            ? null
            : (json["category_id"] is int
                ? json["category_id"]
                : int.tryParse(json["category_id"].toString())),
    category:
        json["category"] is Map<String, dynamic>
            ? ProductCategory.fromJson(json["category"])
            : null, // Only parse if it's actually a Map, otherwise set to null
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
    "discount": discount,
    "stock": stock,
    "image_url": imageUrl,
    "brand_id": brandId,
    "brand": brand?.toJson(),
    "category_id": categoryId,
    "category": category?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

// --- Brand related class (no changes needed here, as it's the input to its fromJson that was the issue) ---
class Brand {
  int? id;
  String? name;
  String? slug;
  String? imageUrl;
  String? description;

  Brand({this.id, this.name, this.slug, this.imageUrl, this.description});

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id:
        json["id"] == null
            ? null
            : (json["id"] is int
                ? json["id"]
                : int.tryParse(json["id"].toString())),
    name: json["name"],
    slug: json["slug"],
    imageUrl: json["image_url"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "image_url": imageUrl,
    "description": description,
  };
}

// --- ProductCategory related class (no changes needed here) ---
class ProductCategory {
  int? id;
  String? name;
  String? slug;
  String? imageUrl;
  String? description;

  ProductCategory({
    this.id,
    this.name,
    this.slug,
    this.imageUrl,
    this.description,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id:
            json["id"] == null
                ? null
                : (json["id"] is int
                    ? json["id"]
                    : int.tryParse(json["id"].toString())),
        name: json["name"],
        slug: json["slug"],
        imageUrl: json["image_url"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "image_url": imageUrl,
    "description": description,
  };
}
