import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thave_luxe_app/helper/preference_handler.dart';
import 'package:thave_luxe_app/tugas_enam_belas/models/order_history_response.dart';

class OrderProvider {
  final String _baseUrl = 'https://thaveluxe.thv.thegrent.com/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await PreferenceHandler.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<OrderData>> getOrderHistory() async {
    final url = Uri.parse('$_baseUrl/history');
    try {
      final headers = await _getHeaders();
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
