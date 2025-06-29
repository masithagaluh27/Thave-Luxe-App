// Path: lib/tugas_lima_belas/models/history_response.dart
// Model diperbarui: menambahkan user data, transaction history,
// serta discount & imageUrl di produk

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
                  json["data"].map((x) => HistoryItem.fromJson(x)),
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
  HistoryUser? user; // 🔥 NEW: detail user
  List<TransactionHistory>?
  transactionHistory; // 🔥 NEW: riwayat status transaksi
  List<HistoryItemProduct>? items;
  int? total;
  DateTime? updatedAt;
  DateTime? createdAt;

  HistoryItem({
    this.id,
    this.userId,
    this.user,
    this.transactionHistory,
    this.items,
    this.total,
    this.updatedAt,
    this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    id: json["id"],
    userId: json["user_id"],
    user: json["user"] == null ? null : HistoryUser.fromJson(json["user"]),
    transactionHistory:
        json["transaction_history"] == null
            ? []
            : List<TransactionHistory>.from(
              json["transaction_history"].map(
                (x) => TransactionHistory.fromJson(x),
              ),
            ),
    items:
        json["items"] == null
            ? []
            : List<HistoryItemProduct>.from(
              json["items"].map((x) => HistoryItemProduct.fromJson(x)),
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
    "user": user?.toJson(),
    "transaction_history":
        transactionHistory == null
            ? []
            : List<dynamic>.from(transactionHistory!.map((x) => x.toJson())),
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
  int? discount; // 🔥 NEW
  String? imageUrl; // 🔥 NEW

  HistoryProduct({
    this.id,
    this.name,
    this.price,
    this.discount,
    this.imageUrl,
  });

  factory HistoryProduct.fromJson(Map<String, dynamic> json) => HistoryProduct(
    id: json["id"],
    name: json["name"],
    price: json["price"],
    discount: json["discount"],
    imageUrl: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "discount": discount,
    "image_url": imageUrl,
  };
}

class HistoryUser {
  int? id;
  String? name;
  String? email;

  HistoryUser({this.id, this.name, this.email});

  factory HistoryUser.fromJson(Map<String, dynamic> json) =>
      HistoryUser(id: json["id"], name: json["name"], email: json["email"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email};
}

class TransactionHistory {
  int? id;
  String? status;
  DateTime? timestamp;

  TransactionHistory({this.id, this.status, this.timestamp});

  factory TransactionHistory.fromJson(Map<String, dynamic> json) =>
      TransactionHistory(
        id: json["id"],
        status: json["status"],
        timestamp:
            json["timestamp"] == null
                ? null
                : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "timestamp": timestamp?.toIso8601String(),
  };
}
