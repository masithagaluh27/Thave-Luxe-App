// lib/tugas_lima_belas/Models/delete_cart_response.dart
import 'dart:convert';

DeleteCartResponse deleteCartResponseFromJson(String str) =>
    DeleteCartResponse.fromJson(json.decode(str));
String deleteCartResponseToJson(DeleteCartResponse data) =>
    json.encode(data.toJson());

class DeleteCartResponse {
  String? message;
  dynamic data; // Usually null for successful deletion

  DeleteCartResponse({this.message, this.data});

  factory DeleteCartResponse.fromJson(Map<String, dynamic> json) =>
      DeleteCartResponse(message: json["message"], data: json["data"]);

  Map<String, dynamic> toJson() => {"message": message, "data": data};
}
