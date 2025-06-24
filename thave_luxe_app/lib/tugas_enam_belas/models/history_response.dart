// lib/tugas_lima_belas/Models/history_response.dart
import 'dart:convert';

HistoryResponse historyResponseFromJson(String str) =>
    HistoryResponse.fromJson(json.decode(str));
String historyResponseToJson(HistoryResponse data) =>
    json.encode(data.toJson());

class HistoryResponse {
  String? message;
  List<HistoryItem>? data;

  HistoryResponse({this.message, this.data});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) =>
      HistoryResponse(
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<HistoryItem>.from(
                  json["data"]!.map((x) => HistoryItem.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class HistoryItem {
  int? id;
  int? userId;
  List<HistoryItemProduct>? items;
  int? total;
  DateTime? updatedAt;
  DateTime? createdAt;

  HistoryItem({
    this.id,
    this.userId,
    this.items,
    this.total,
    this.updatedAt,
    this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    id: json["id"],
    userId: json["user_id"],
    items:
        json["items"] == null
            ? []
            : List<HistoryItemProduct>.from(
              json["items"]!.map((x) => HistoryItemProduct.fromJson(x)),
            ),
    total: json["total"],
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "items":
        items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "total": total,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
  };
}

class HistoryItemProduct {
  HistoryProduct? product;
  int? quantity;

  HistoryItemProduct({this.product, this.quantity});

  factory HistoryItemProduct.fromJson(Map<String, dynamic> json) =>
      HistoryItemProduct(
        product:
            json["product"] == null
                ? null
                : HistoryProduct.fromJson(json["product"]),
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
    "product": product?.toJson(),
    "quantity": quantity,
  };
}

class HistoryProduct {
  int? id;
  String? name;
  int? price;

  HistoryProduct({this.id, this.name, this.price});

  factory HistoryProduct.fromJson(Map<String, dynamic> json) =>
      HistoryProduct(id: json["id"], name: json["name"], price: json["price"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "price": price};
}
