// lib/tugas_lima_belas/Models/error_response.dart
import 'dart:convert';

ErrorResponse errorResponseFromJson(String str) =>
    ErrorResponse.fromJson(json.decode(str));
String errorResponseToJson(ErrorResponse data) => json.encode(data.toJson());

class ErrorResponse {
  String? message;
  Map<String, List<String>>? errors;

  ErrorResponse({this.message, this.errors});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
    message: json["message"],
    errors:
        json["errors"] == null
            ? null
            : Map.from(json["errors"]).map(
              (k, v) => MapEntry<String, List<String>>(
                k,
                List<String>.from(v.map((x) => x)),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "errors":
        errors == null
            ? null
            : Map.from(errors!).map(
              (k, v) => MapEntry<String, dynamic>(
                k,
                List<dynamic>.from(v.map((x) => x)),
              ),
            ),
  };
}
