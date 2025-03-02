import 'package:currencyexchangerate/graph.dart';
import 'package:currencyexchangerate/predict.dart';
import 'package:flutter/material.dart';
import 'currency_calculator.dart';
import 'fixer_service.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _historicalRates;

  @override
  void initState() {
    print('home');
    super.initState();
      _tabController = TabController(length: 4, vsync: this);

      // Fetch exchange rates for the last 3 days
      _historicalRates = fetchThreeDaysRates();
  }

  // Helper function to fetch exchange rates for the last 3 days
  Future<Map<String, dynamic>> fetchThreeDaysRates() async {
    try {
      // Fetch rates for three consecutive days (replace with actual dates as needed)
      final rateDay1 = await FixerService.getHistoricalRates('2023-10-10', 'EUR', 'USD');
      final rateDay2 = await FixerService.getHistoricalRates('2023-10-11', 'EUR', 'USD');
      final rateDay3 = await FixerService.getHistoricalRates('2023-10-12', 'EUR', 'USD');


      return {
        if (rateDay1.containsKey('rates')) '2023-10-10': rateDay1['rates']['USD'],
        if (rateDay2.containsKey('rates')) '2023-10-11': rateDay2['rates']['USD'],
        if (rateDay3.containsKey('rates')) '2023-10-12': rateDay3['rates']['USD'],
      };
      
    } catch (e) {
      print('Error fetching historical rates: $e');
      return {};
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          CurrencyCalculator(),
          GraphTab(historicalRates: _historicalRates),
          PredictScreen(),
        ],
      ),
      bottomNavigationBar: Material(
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Calculator', icon: Icon(Icons.calculate)),
            Tab(text: 'Rates', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Prediction', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
    );
  }
}
