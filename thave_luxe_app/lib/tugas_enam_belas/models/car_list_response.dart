// lib/tugas_lima_belas/Models/cart_list_response.dart
import 'dart:convert';

CartListResponse cartListResponseFromJson(String str) =>
    CartListResponse.fromJson(json.decode(str));
String cartListResponseToJson(CartListResponse data) =>
    json.encode(data.toJson());

class CartListResponse {
  String? message;
  List<CartItem>? data;

  CartListResponse({this.message, this.data});

  factory CartListResponse.fromJson(Map<String, dynamic> json) =>
      CartListResponse(
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<CartItem>.from(
                  json["data"]!.map((x) => CartItem.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CartItem {
  int? id;
  ProductInCart? product;
  int? quantity;
  int? subtotal;

  CartItem({this.id, this.product, this.quantity, this.subtotal});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json["id"],
    product:
        json["product"] == null
            ? null
            : ProductInCart.fromJson(json["product"]),
    quantity: json["quantity"],
    subtotal: json["subtotal"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product": product?.toJson(),
    "quantity": quantity,
    "subtotal": subtotal,
  };
}

class ProductInCart {
  int? id;
  String? name;
  int? price;

  ProductInCart({this.id, this.name, this.price});

  factory ProductInCart.fromJson(Map<String, dynamic> json) =>
      ProductInCart(id: json["id"], name: json["name"], price: json["price"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "price": price};
}
