import 'package:flutter/material.dart';

int? _safeParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt(); // Handles double values like 123.0
  return null;
}

double? _safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// -----------------------------------------------------------------------------
// Base API Response Model
// -----------------------------------------------------------------------------

class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;
  final String? error; // For error messages that are not exceptions

  ApiResponse({required this.status, this.message, this.data, this.error});

  /// Factory constructor to create an ApiResponse from a JSON map with data.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final String? apiMessage = json['message'] as String?;
    final String? apiError = json['error'] as String?;
    final dynamic rawData = json['data'];

    T? parsedData;
    String inferredStatus;

    // Logic to infer status:
    // 1. If an explicit 'status' field exists and is 'success' or 'error', use it.
    // 2. If 'data' is present, infer 'success'.
    // 3. If 'error' is present (and 'data' is null), infer 'error'.
    // 4. Otherwise, default to 'unknown' or 'error' if desired.

    // Try to get status directly, if provided by API (though your API doesn't seem to have it)
    final String? directStatus = json['status'] as String?;

    if (directStatus == 'success') {
      inferredStatus = 'success';
    } else if (directStatus == 'error') {
      inferredStatus = 'error';
    } else if (rawData != null) {
      // If 'data' is present, it's generally a success response
      inferredStatus = 'success';
      try {
        parsedData = fromJsonT(rawData);
      } catch (e) {
        debugPrint('Error parsing data in ApiResponse.fromJson: $e');
        inferredStatus = 'error'; // Data parsing failed, treat as error
      }
    } else if (apiError != null) {
      // If no data but an error message is present
      inferredStatus = 'error';
    } else {
      // Fallback if none of the above conditions met
      inferredStatus = 'unknown'; // Or 'error' if you want to be stricter
    }

    return ApiResponse<T>(
      status: inferredStatus,
      message: apiMessage,
      data: parsedData,
      error: apiError,
    );
  }

  /// Factory constructor for responses without data (e.g., logout, delete success message).
  /// This will also populate the 'status' field based on 'error' field.
  factory ApiResponse.fromJsonNoData(Map<String, dynamic> json) {
    final String? apiMessage = json['message'] as String?;
    final String? apiError = json['error'] as String?;

    String inferredStatus;
    // Try to get status directly, if provided by API
    final String? directStatus = json['status'] as String?;

    if (directStatus == 'success') {
      inferredStatus = 'success';
    } else if (directStatus == 'error') {
      inferredStatus = 'error';
    } else if (apiError != null) {
      inferredStatus = 'error';
    } else {
      inferredStatus =
          'success'; // Assume success if no error and no data expected
    }

    return ApiResponse<T>(
      status: inferredStatus,
      message: apiMessage,
      data: null, // No data to parse for void type
      error: apiError,
    );
  }

  // Factory constructor for creating an ERROR ApiResponse explicitly in code
  factory ApiResponse.error({
    String? message,
    String? error, // Use this for the actual error content
    String status = 'error', // Default status for errors
  }) {
    return ApiResponse<T>(
      status: status,
      message: message, // A general message about the error
      error:
          error ??
          message, // Prioritize the 'error' parameter, fallback to message
      data: null,
    );
  }
}

/// Model for user data returned from authentication.
class User {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _safeParseInt(json['id']),
      name: json['name'] as String?,
      email: json['email'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Model for login/register response data (includes token and user).
class AuthData {
  final String? token;
  final User? user;

  AuthData({this.token, this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

// -----------------------------------------------------------------------------
// Product Models
// -----------------------------------------------------------------------------

/// Model for a Brand.
class Brand {
  final int? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  Brand({this.id, this.name, this.createdAt, this.updatedAt});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: _safeParseInt(json['id']),
      name: json['name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  get logoUrl => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Model for a Category.
class Category {
  final int? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  Category({this.id, this.name, this.createdAt, this.updatedAt});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _safeParseInt(json['id']),
      name: json['name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Model for a Product.
class Product {
  final int? id;
  final String? name;
  final String? description;
  final int? price;
  final int? stock;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final double? discount;
  final List<String>? imageUrls; // List of image URLs
  final String? createdAt;
  final String? updatedAt;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.discount,
    this.imageUrls,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _safeParseInt(json['id']),
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: _safeParseInt(json['price']),
      stock: _safeParseInt(json['stock']),
      categoryId: _safeParseInt(json['category_id']),
      categoryName:
          json['category']
              as String?, // API uses 'category' not 'category_name'
      brandId: _safeParseInt(json['brand_id']),
      brandName: json['brand'] as String?, // API uses 'brand' not 'brand_name'
      discount: _safeParseDouble(json['discount']),
      // Fixed: Change 'images' to 'image_urls' to match API response
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'category_name':
          categoryName, // Keep for serialization consistency if API expects it
      'brand_id': brandId,
      'brand_name':
          brandName, // Keep for serialization consistency if API expects it
      'discount': discount,
      'image_urls':
          imageUrls, // Changed to 'image_urls' for serialization consistency
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// -----------------------------------------------------------------------------
// Cart Models
// -----------------------------------------------------------------------------

/// Simplified Product model for use within CartItem and CheckoutItem.
class CartProduct {
  final int? id;
  final String? name;
  final int? price;
  final int? stock; // Adding stock to CartProduct for quantity checks
  final List<String>? imageUrls; // Add imageUrls to CartProduct for display

  CartProduct({this.id, this.name, this.price, this.stock, this.imageUrls});

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: _safeParseInt(json['id']),
      name: json['name'] as String?,
      price: _safeParseInt(json['price']),
      stock: _safeParseInt(json['stock']),
      // Fixed: Change 'images' to 'image_urls' to match API response
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'image_urls':
          imageUrls, // Changed to 'image_urls' for serialization consistency
    };
  }
}

/// Model for a single item in the user's cart.
class CartItem {
  final int? id;
  final int? userId;
  final int? productId;
  final CartProduct? product; // Simplified product info
  final int? quantity;
  final double? subtotal;
  final String? createdAt;
  final String? updatedAt;

  CartItem({
    this.id,
    this.userId,
    this.productId,
    this.product,
    this.quantity,
    this.subtotal,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _safeParseInt(json['id']),
      userId: _safeParseInt(json['user_id']),
      productId: _safeParseInt(json['product_id']),
      product:
          json['product'] != null
              ? CartProduct.fromJson(json['product'])
              : null,
      quantity: _safeParseInt(json['quantity']),
      subtotal: _safeParseDouble(json['subtotal']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product': product?.toJson(),
      'quantity': quantity,
      'subtotal': subtotal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// -----------------------------------------------------------------------------
// Checkout Models
// -----------------------------------------------------------------------------

/// Simplified Product model used within CheckoutItem.
class CheckoutProduct {
  final int? id;
  final String? name;
  final int? price;
  final double? discount; // Added discount
  final List<String>? imageUrls; // Added imageUrls

  CheckoutProduct({
    this.id,
    this.name,
    this.price,
    this.discount,
    this.imageUrls,
  });

  factory CheckoutProduct.fromJson(Map<String, dynamic> json) {
    return CheckoutProduct(
      id: _safeParseInt(json['id']),
      name: json['name'] as String?,
      price: _safeParseInt(json['price']),
      discount: _safeParseDouble(json['discount']), // Parse discount
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(), // Parse image_urls
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'discount': discount,
      'image_urls':
          imageUrls, // Changed to 'image_urls' for serialization consistency
    };
  }
}

/// Model for a single item in the checkout response.
class CheckoutItem {
  final CheckoutProduct? product;
  final int? quantity;

  CheckoutItem({this.product, this.quantity});

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      product:
          json['product'] != null
              ? CheckoutProduct.fromJson(json['product'])
              : null,
      quantity: _safeParseInt(json['quantity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'product': product?.toJson(), 'quantity': quantity};
  }
}

/// Model for the checkout response data.
class CheckoutResponseData {
  final int? id;
  final int? userId;
  final List<CheckoutItem>? items;
  final int? total;
  final String? updatedAt;
  final String? createdAt;

  CheckoutResponseData({
    this.id,
    this.userId,
    this.items,
    this.total,
    this.updatedAt,
    this.createdAt,
  });

  factory CheckoutResponseData.fromJson(Map<String, dynamic> json) {
    return CheckoutResponseData(
      id: _safeParseInt(json['id']),
      userId: _safeParseInt(json['user_id']),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => CheckoutItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      total: _safeParseInt(json['total']),
      updatedAt: json['updated_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items?.map((e) => e.toJson()).toList(),
      'total': total,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }
}

// -----------------------------------------------------------------------------
// History Models
// -----------------------------------------------------------------------------

class HistoryProduct {
  final int? id;
  final String? name;
  final String? description;
  final int? price;
  final int? stock;
  final int? categoryId;
  final String? categoryName; // API uses 'category'
  final int? brandId;
  final String? brandName; // API uses 'brand'
  final double? discount;
  final List<String>? imageUrls; // List of image URLs
  final String? createdAt;
  final String? updatedAt;

  HistoryProduct({
    this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.discount,
    this.imageUrls,
    this.createdAt,
    this.updatedAt,
  });

  factory HistoryProduct.fromJson(Map<String, dynamic> json) {
    return HistoryProduct(
      id: _safeParseInt(json['id']),
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: _safeParseInt(json['price']),
      stock: _safeParseInt(json['stock']),
      categoryId: _safeParseInt(json['category_id']),
      categoryName: json['category'] as String?, // Fixed: Use 'category'
      brandId: _safeParseInt(json['brand_id']),
      brandName: json['brand'] as String?, // Fixed: Use 'brand'
      discount: _safeParseDouble(json['discount']),
      // Fixed: Change 'images' to 'image_urls' to match API response
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'category_name': categoryName,
      'brand_id': brandId,
      'brand_name': brandName,
      'discount': discount,
      'image_urls':
          imageUrls, // Changed to 'image_urls' for serialization consistency
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class HistoryItem {
  final int? id;
  final int? checkoutId;
  final int? productId;
  final HistoryProduct? product; // Using HistoryProduct
  final int? quantity;
  final int? price; // Price at the time of checkout
  final String? createdAt;
  final String? updatedAt;

  HistoryItem({
    this.id,
    this.checkoutId,
    this.productId,
    this.product,
    this.quantity,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: _safeParseInt(json['id']),
      checkoutId: _safeParseInt(json['checkout_id']),
      productId: _safeParseInt(json['product_id']),
      product:
          json['product'] != null
              ? HistoryProduct.fromJson(json['product'])
              : null,
      quantity: _safeParseInt(json['quantity']),
      price: _safeParseInt(json['price']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkout_id': checkoutId,
      'product_id': productId,
      'product': product?.toJson(),
      'quantity': quantity,
      'price': price,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class History {
  final int? id;
  final int? userId;
  final List<HistoryItem>? items; // List of HistoryItem
  final int? total;
  final String? createdAt;
  final String? updatedAt;

  History({
    this.id,
    this.userId,
    this.items,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: _safeParseInt(json['id']),
      userId: _safeParseInt(json['user_id']),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      total: _safeParseInt(json['total']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items?.map((e) => e.toJson()).toList(),
      'total': total,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
