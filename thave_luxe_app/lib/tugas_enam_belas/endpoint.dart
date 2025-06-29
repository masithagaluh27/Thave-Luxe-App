// lib/tugas_enam_belas/endpoint.dart

class Endpoint {
  static const String baseUrl = 'https://apptoko.mobileprojp.com/api';
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String profile = '$baseUrl/user';
  static const String products = '$baseUrl/products';
  static const String getCart = '$baseUrl/products';
  static String productDetail(int id) =>
      '$baseUrl/products/$id'; // <--- NEW: Product specific detail
  static const String addToCart = '$baseUrl/cart/add';
  static const String listCart = '$baseUrl/cart';
  static String deleteCartItem(int cartItemId) => '$baseUrl/cart/$cartItemId';
  static const String checkout = '$baseUrl/checkout';
  static const String transactionHistory = '$baseUrl/history';
  static const String logout = '$baseUrl/logout';

  // --- Endpoints for Brands ---
  static const String brands = '$baseUrl/brands';
  static String brandDetail(int id) => '$baseUrl/brands/$id';

  // --- Endpoints for Categories ---
  static const String categories = '$baseUrl/categories';
  static String categoryDetail(int id) => '$baseUrl/categories/$id';
}
