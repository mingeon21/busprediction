import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class ExchangeRateService {
  static const String apiKey = '1f3bd07c1ba4ceff4ea12246';
  static const String baseUrl = 'https://v6.exchangerate-api.com/v6';

  // Fetch real-time exchange rates for specific base and target currencies
  static Future<Map<String, double>> getRealTimeRates(String base) async {
    final url = Uri.parse('$baseUrl/$apiKey/latest/$base');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Filter for the required currencies
        final Map<String, double> filteredRates = {};
        const List<String> targetCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'AUD'];
        targetCurrencies.forEach((currency) {
          if (data['conversion_rates'][currency] != null) {
            filteredRates[currency] = data['conversion_rates'][currency].toDouble();
          }
        });
        return filteredRates;
      } else {
        throw Exception('Failed to load real-time exchange rates');
      }
    } catch (e) {
      print('Error fetching real-time data: $e');
      return {};
    }
  }

  // Fetch exchange rate for a specific date between base and target currencies
  static Future<Map<String, dynamic>> getExchangeRatesForDate(
      String date, String base, String target) async {
    final url = Uri.parse('$baseUrl/$apiKey/pair/$base/$target');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'date': date,
          'rate': data['conversion_rate'],
        };
      } else {
        throw Exception('Failed to load exchange rates for $date');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return {};
    }
  }

  // Fetch daily exchange rates for all days in a specific month
  static Future<Map<String, double>> fetchMonthlyRates(
      String base, String target, int year, int month) async {
    final Map<String, double> monthlyRates = {};
    final int daysInMonth = DateTime(year, month + 1, 0).day;

    try {
      for (int day = 1; day <= daysInMonth; day++) {
        final String date = DateFormat('yyyy-MM-dd').format(
          DateTime(year, month, day),
        );

        final rateData = await getExchangeRatesForDate(date, base, target);
        if (rateData.isNotEmpty) {
          monthlyRates[date] = rateData['rate'];
        }
      }
      return monthlyRates;
    } catch (e) {
      print('Error fetching monthly rates: $e');
      return {};
    }
  }
}
