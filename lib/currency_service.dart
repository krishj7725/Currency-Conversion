import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExchangeRateApi { 
  Future<Map<String, dynamic>> getRates() async {
    try {
      // Accessing the key securely
      final String apiKey = dotenv.env['EXCHANGE_RATE_API_KEY'] ?? '';
      
      final url = Uri.parse('https://v6.exchangerate-api.com/v6/$apiKey/latest/USD');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['conversion_rates'];
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      throw Exception("Network Error");
    }
  }
}