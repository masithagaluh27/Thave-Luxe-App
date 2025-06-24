// lib/tugas_lima_belas/Models/add_to_cart_response.dart
import 'dart:convert';

AddToCartResponse addToCartResponseFromJson(String str) =>
    AddToCartResponse.fromJson(json.decode(str));
String addToCartResponseToJson(AddToCartResponse data) =>
    json.encode(data.toJson());

class AddToCartResponse {
  String? message;
  CartItemAdded? data;

  AddToCartResponse({this.message, this.data});

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) =>
      AddToCartResponse(
        message: json["message"],
        data:
            json["data"] == null ? null : CartItemAdded.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class CartItemAdded {
  int? userId;
  int? productId;
  int? quantity;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  CartItemAdded({
    this.userId,
    this.productId,
    this.quantity,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory CartItemAdded.fromJson(Map<String, dynamic> json) => CartItemAdded(
    userId: json["user_id"],
    productId: json["product_id"],
    quantity: json["quantity"],
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "product_id": productId,
    "quantity": quantity,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}
