import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GraphTab extends StatefulWidget {
  final Future<Map<String, dynamic>> historicalRates;

  GraphTab({required this.historicalRates});

  @override
  _GraphTabState createState() => _GraphTabState();
}

class _GraphTabState extends State<GraphTab> {
  String selectedXCurrency = 'EUR';
  String selectedYCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.historicalRates,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          var rates = snapshot.data!;

          if (rates.isEmpty) {
            return Center(child: Text('No valid data available'));
          }

          List<String> dates = rates.keys.toList()..sort();
          List<FlSpot> spots = [];

          double minRate = double.infinity;
          double maxRate = double.negativeInfinity;

          for (int i = 0; i < dates.length; i++) {
            String date = dates[i];
            double? rate = rates[date];
            if (rate != null) {
              spots.add(FlSpot(i.toDouble(), rate));
              if (rate < minRate) minRate = rate;
              if (rate > maxRate) maxRate = rate;
            }
          }

          double interval = ((maxRate - minRate) / 5).clamp(0.01, double.infinity);

          return Padding(
            padding: const EdgeInsets.all(16.0), // Uniform padding for better layout
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Historical Exchange Rates',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCurrencyButton('X-Axis', selectedXCurrency, (value) {
                      setState(() => selectedXCurrency = value!);
                    }),
                    _buildCurrencyButton('Y-Axis', selectedYCurrency, (value) {
                      setState(() => selectedYCurrency = value!);
                    }),
                  ],
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20.0, // Extra padding for the X-axis label
                      right: 16.0,  // Extra padding on the right to avoid date cutoff
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Padding(
                              padding: const EdgeInsets.only(top: 12.0), // Extra padding to avoid cutoff
                              child: const Text(
                                'Date',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 50, // Increase space for X-axis labels
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                                  String date = dates[value.toInt()];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Text(
                                      DateFormat('MM/dd').format(DateTime.parse(date)),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                'Rate (${selectedYCurrency}) per (${selectedXCurrency})',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: interval,
                              reservedSize: 60, // Reserve space for Y-axis labels
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(4),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        minX: 0,
                        maxX: (dates.length - 1).toDouble(),
                        minY: minRate - interval,
                        maxY: maxRate + interval,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildCurrencyButton(
      String axis, String selectedCurrency, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: selectedCurrency,
      items: ['USD', 'EUR', 'GBP', 'JPY', 'AUD']
          .map((currency) => DropdownMenuItem<String>(
                value: currency,
                child: Text(currency),
              ))
          .toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      underline: Container(
        height: 2,
        color: Colors.blue,
      ),
      icon: const Icon(Icons.arrow_drop_down),
      dropdownColor: Colors.white,
    );
  }
}
