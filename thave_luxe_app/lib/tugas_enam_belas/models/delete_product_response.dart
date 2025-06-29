import 'dart:convert';

DeleteProductResponse deleteProductResponseFromJson(String str) =>
    DeleteProductResponse.fromJson(json.decode(str));
String deleteProductResponseToJson(DeleteProductResponse data) =>
    json.encode(data.toJson());

class DeleteProductResponse {
  final String? message;
  final dynamic data; // Will typically be null for a delete success

  DeleteProductResponse({this.message, this.data});

  factory DeleteProductResponse.fromJson(Map<String, dynamic> json) =>
      DeleteProductResponse(
        message: json["message"],
        data: json["data"], // Data is null, so just take it as is
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data};
}
