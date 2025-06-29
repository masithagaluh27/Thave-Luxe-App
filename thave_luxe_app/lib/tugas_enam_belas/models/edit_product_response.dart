import 'dart:convert';
import 'package:thave_luxe_app/tugas_enam_belas/models/produk_response.dart'; // Import the existing Product model

EditProductResponse editProductResponseFromJson(String str) =>
    EditProductResponse.fromJson(json.decode(str));
String editProductResponseToJson(EditProductResponse data) =>
    json.encode(data.toJson());

class EditProductResponse {
  final String? message;
  final Product? data; // The updated product details

  EditProductResponse({this.message, this.data});

  factory EditProductResponse.fromJson(Map<String, dynamic> json) =>
      EditProductResponse(
        message: json["message"],
        data: json["data"] == null ? null : Product.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}
