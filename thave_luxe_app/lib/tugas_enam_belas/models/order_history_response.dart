import 'dart:convert';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'; // Import Product model

OrderHistoryResponse orderHistoryResponseFromJson(String str) =>
    OrderHistoryResponse.fromJson(json.decode(str));

String orderHistoryResponseToJson(OrderHistoryResponse data) =>
    json.encode(data.toJson());

class OrderHistoryResponse {
  String? message;
  List<OrderData>? data;

  OrderHistoryResponse({this.message, this.data});

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) =>
      OrderHistoryResponse(
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<OrderData>.from(
                  json["data"]!.map((x) => OrderData.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class OrderData {
  int? id;
  int? userId;
  List<OrderItem>? items;
  int? total;
  String? createdAt;
  String? updatedAt;

  OrderData({
    this.id,
    this.userId,
    this.items,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
    id: json["id"],
    userId: json["user_id"],
    items:
        json["items"] == null
            ? []
            : List<OrderItem>.from(
              json["items"]!.map((x) => OrderItem.fromJson(x)),
            ),
    total: json["total"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "items":
        items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "total": total,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class OrderItem {
  Product? product; // Using the existing Product model for consistency
  int? quantity;

  OrderItem({this.product, this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "product": product?.toJson(),
    "quantity": quantity,
  };
}
