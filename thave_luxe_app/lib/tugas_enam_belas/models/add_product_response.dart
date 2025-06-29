import 'dart:convert';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'; // Import the existing Product model

AddProductResponse addProductResponseFromJson(String str) =>
    AddProductResponse.fromJson(json.decode(str));
String addProductResponseToJson(AddProductResponse data) =>
    json.encode(data.toJson());

class AddProductResponse {
  final String? message;
  final Product? data; // The newly added product details

  AddProductResponse({this.message, this.data});

  factory AddProductResponse.fromJson(Map<String, dynamic> json) =>
      AddProductResponse(
        message: json["message"],
        data: json["data"] == null ? null : Product.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}
