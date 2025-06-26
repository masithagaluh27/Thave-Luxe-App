import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/order_history_response.dart'; // Import the new OrderHistoryResponse

/// `OrderProvider` handles all API interactions related to order data.
class OrderProvider {
  final String _baseUrl =
      'https://thaveluxe.thv.thegrent.com/api'; // Your base API URL

  // Private helper to get the authorization token from preferences
  Future<Map<String, String>> _getHeaders() async {
    final token = await PreferenceHandler.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetches the order history for the authenticated user (or all if admin).
  /// Throws an exception if the API call fails or returns an error.
  Future<List<OrderData>> getOrderHistory() async {
    final url = Uri.parse(
      '$_baseUrl/history',
    ); // As per Postman collection: /api/history
    try {
      final headers = await _getHeaders(); // Requires authentication
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final OrderHistoryResponse orderHistoryResponse =
            OrderHistoryResponse.fromJson(jsonResponse);
        return orderHistoryResponse.data ?? [];
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          'Failed to load order history: ${errorBody['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to get order history: $e');
    }
  }
}
