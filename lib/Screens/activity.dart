import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_management/Screens/home_page.dart';

class HealthParametersPage extends StatefulWidget {
  const HealthParametersPage({super.key});

  @override
  HealthParametersPageState createState() => HealthParametersPageState();
}

class HealthParametersPageState extends State<HealthParametersPage> {
  String _selectedPeriod = 'Daily';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  Map<String, List<FlSpot>> data = {
    'Daily': [
      FlSpot(0, 120), // 0h
      FlSpot(6, 122), // 6h
      FlSpot(12, 118), // 12h
      FlSpot(18, 125), // 18h
      FlSpot(24, 121), // 24h
    ],
    'Weekly': [
      FlSpot(1, 120), // Day 1
      FlSpot(2, 121), // Day 2
      FlSpot(3, 119), // Day 3
      FlSpot(4, 122), // Day 4
      FlSpot(5, 118), // Day 5
      FlSpot(6, 124), // Day 6
      FlSpot(7, 121), // Day 7
    ],
    'Monthly': [
      FlSpot(1, 120), // Week 1
      FlSpot(2, 122), // Week 2
      FlSpot(3, 118), // Week 3
      FlSpot(4, 125), // Week 4
    ],
  };

  /// Function to format x-axis labels based on selected period
  Widget _getXAxisLabels(double value, TitleMeta meta) {
    switch (_selectedPeriod) {
      case 'Daily':
        return Text("${value.toInt()}h"); // Time in hours
      case 'Weekly':
        return Text("${value.toInt()}"); // Day number
      case 'Monthly':
        return Text("Week ${value.toInt()}"); // Week number
      default:
        return Text(value.toInt().toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Parameters"),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Period:", style: TextStyle(fontSize: 18)),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPeriod = newValue!;
                    });
                  },
                  items: _periods.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: AspectRatio(
                aspectRatio: 1, // Make it square
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1), // Optional border
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _getXAxisLabels, // Custom x-axis labels
                          ),
                        ),
                      ),
                      barGroups: data[_selectedPeriod]!.map((e) {
                        return BarChartGroupData(
                          x: e.x.toInt(),
                          barRods: [BarChartRodData(toY: e.y, color: Colors.blue)],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
