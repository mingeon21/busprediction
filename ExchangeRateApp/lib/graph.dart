import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GraphTab extends StatelessWidget {
  final Future<Map<String, dynamic>> historicalRates;

  GraphTab({required this.historicalRates});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: historicalRates,
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

          // Prepare data points (FlSpot) and calculate min/max rates for the y-axis
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false), // Disable extra grid lines
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Remove top titles
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Remove right titles
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, // Ensure one label per date
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < dates.length) {
                          String date = dates[value.toInt()];
                          return Text(
                            DateFormat('MM/dd').format(DateTime.parse(date)),
                            style: TextStyle(fontSize: 12),
                          );
                        }
                        return const SizedBox.shrink(); // Prevent out-of-bounds errors
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxRate - minRate) / 2, // Ensure 3 labels on y-axis
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(2),
                          style: TextStyle(fontSize: 12),
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
                maxX: 2, // Set range for 3 points (0, 1, 2)
                minY: minRate,
                maxY: maxRate,
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
          );
        }
      },
    );
  }
}
