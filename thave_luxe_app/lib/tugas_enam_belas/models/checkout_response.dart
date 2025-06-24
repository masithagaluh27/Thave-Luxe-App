// lib/tugas_lima_belas/Models/checkout_response.dart
import 'dart:convert';

CheckoutResponse checkoutResponseFromJson(String str) =>
    CheckoutResponse.fromJson(json.decode(str));
String checkoutResponseToJson(CheckoutResponse data) =>
    json.encode(data.toJson());

class CheckoutResponse {
  String? message;
  CheckoutData? data;

  CheckoutResponse({this.message, this.data});

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) =>
      CheckoutResponse(
        message: json["message"],
        data: json["data"] == null ? null : CheckoutData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class CheckoutData {
  int? userId;
  List<CheckoutItem>? items;
  int? total;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  CheckoutData({
    this.userId,
    this.items,
    this.total,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) => CheckoutData(
    userId: json["user_id"],
    items:
        json["items"] == null
            ? []
            : List<CheckoutItem>.from(
              json["items"]!.map((x) => CheckoutItem.fromJson(x)),
            ),
    total: json["total"],
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "items":
        items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "total": total,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}

class CheckoutItem {
  ProductInCheckout? product;
  int? quantity;

  CheckoutItem({this.product, this.quantity});

  factory CheckoutItem.fromJson(Map<String, dynamic> json) => CheckoutItem(
    product:
        json["product"] == null
            ? null
            : ProductInCheckout.fromJson(json["product"]),
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "product": product?.toJson(),
    "quantity": quantity,
  };
}

class ProductInCheckout {
  int? id;
  String? name;
  int? price;

  ProductInCheckout({this.id, this.name, this.price});

  factory ProductInCheckout.fromJson(Map<String, dynamic> json) =>
      ProductInCheckout(
        id: json["id"],
        name: json["name"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {"id": id, "name": name, "price": price};
}
