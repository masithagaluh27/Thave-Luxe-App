class Endpoint {
  static const String baseUrl = 'https://apptoko.mobileprojp.com/api';
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String profile = '$baseUrl/profile';
  static const String profileUpdate = '$baseUrl/profile';
  static const String products = '$baseUrl/products';
  static const String addToCart = '$baseUrl/cart/add';
  static const String listCart = '$baseUrl/cart';
  static String deleteCartItem(int cartItemId) => '$baseUrl/cart/$cartItemId';
  static const String checkout = '$baseUrl/checkout';
  static const String transactionHistory = '$baseUrl/history';
  static const String logout = '$baseUrl/logout'; // This endpoint is defined

  // --- Endpoints for Brands ---
  static const String brands = '$baseUrl/brands';
  static String brandDetail(int id) => '$baseUrl/brands/$id';

  // --- Endpoints for Categories ---
  static const String categories = '$baseUrl/categories';
  static String categoryDetail(int id) => '$baseUrl/categories/$id';
}
