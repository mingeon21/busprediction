import 'package:flutter/material.dart';
import 'currency_calculator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          Center(child: Text('Graph & Rates Content')),
          Center(child: Text('Prediction Content')),
        ],
      ),
      bottomNavigationBar: Material(  // Wrap TabBar in Material
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Currency Calculator', icon: Icon(Icons.calculate)),   // Calculator icon
            Tab(text: 'Graph & Rates', icon: Icon(Icons.bar_chart)),          // Bar chart icon
            Tab(text: 'Prediction', icon: Icon(Icons.trending_up)),           // Trending icon
          ],
        ),
      ),
    );
  }
}
