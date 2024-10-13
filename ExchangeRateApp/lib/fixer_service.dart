import 'dart:convert';
import 'package:http/http.dart' as http;

class FixerService {

  // Fetch historical exchange rates
  static Future<Map<String, dynamic>> getHistoricalRates(
      String date, String base, String symbols) async {
        String apiKey = 'b6296e6c0baecba5eb882bb654d4768b';
        String baseUrl = 'http://data.fixer.io/api';
    final url = Uri.parse(
        '$baseUrl/$date?access_key=$apiKey&base=$base&symbols=$symbols');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return {};
    }
  }
}
