import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_management/Screens/google_fit.dart';

class ActivityPage extends StatefulWidget {
  final String title;

  const ActivityPage({super.key, required this.title});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _selectedPeriod = 'daily';
  final List<String> _periods = ['daily', 'weekly', 'monthly'];
  late String accessToken;
  List<FlSpot> chartData = [];
  bool isLoading = true;
  bool hasError = false;
  double minY = 0;
  double maxY = 100;
  double? _maxDataValue;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        _maxDataValue = null;
      });

      final token = await GoogleFitService().getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      accessToken = token;

      switch (widget.title) {
        case 'Steps Taken':
          chartData = await _getStepsData();
          break;
        case 'Heart Rate':
          chartData = await _getHeartRateData();
          break;
        case 'Calories Burned':
          chartData = await _getCaloriesData();
          break;
        case 'BP Level':
          chartData = await _getBloodPressureData();
          break;
        case 'SpO2 Level':
          chartData = await _getSpO2Data();
          break;
        case 'Sleep Quality':
          chartData = await _getSleepData();
          break;
        case 'Body Temperature':
          chartData = await _getBodyTemperatureData();
          break;
        case 'Distance Travelled':
          chartData = await _getDistance();
          break;
        case 'Blood Glucose':
          chartData = await _getBloodGlucoseData();
          break;
        default:
          chartData = [];
      }
      if (chartData.isNotEmpty) {
        _maxDataValue = chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
        maxY = _calculateOptimalMaxY(_maxDataValue!);
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double _calculateOptimalMaxY(double maxValue) {
    if (maxValue <= 0) return 100; // Default fallback

    // For values in thousands
    if (maxValue > 1000) {
      return (maxValue * 1.2).ceilToDouble(); // Add 20% padding
    }
    // For values in hundreds
    else if (maxValue > 100) {
      return (maxValue * 1.2).ceilToDouble() / 10 * 10; // Round to nearest 10
    }
    // For smaller values
    else {
      return (maxValue * 1.2).ceilToDouble(); // Add 20% padding
    }
  }

  Future<List<FlSpot>> _getStepsData() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getSteps(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getSteps(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getSteps(accessToken, 'monthly'));
      default:
        return [];
    }
  }

  Future<List<FlSpot>> _getHeartRateData() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getHeartRate(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getHeartRate(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getHeartRate(accessToken, 'monthly'));
      default:
        return [];
    }
  }

  Future<List<FlSpot>> _getCaloriesData() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getCaloriesBurned(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getCaloriesBurned(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getCaloriesBurned(accessToken, 'monthly'));
      default:
        return [];
    }
  }
  Future<List<FlSpot>> _getBloodPressureData() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getBloodPressure(accessToken,'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getBloodPressure(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getBloodPressure(accessToken, 'monthly'));
      default:
        return [];
    }
  }

  Future<List<FlSpot>> _getSpO2Data() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getOxygenSaturation(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getOxygenSaturation(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getOxygenSaturation(accessToken, 'monthly'));
      default:
        return [];
    }
  }

  Future<List<FlSpot>> _getSleepData() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getSleepData(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getSleepData(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getSleepData(accessToken, 'monthly'));
      default:
        return [];
    }
  }Future<List<FlSpot>> _getBodyTemperatureData() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getBodyTemperature(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getBodyTemperature(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getBodyTemperature(accessToken, 'monthly'));
      default:
        return [];
    }
  }
  Future<List<FlSpot>> _getDistance() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getDistance(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getDistance(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getDistance(accessToken, 'monthly'));
      default:
        return [];
    }
  }
  Future<List<FlSpot>> _getBloodGlucoseData() async {
    switch (_selectedPeriod) {
      case 'daily':
        return _generateHourlyData(await GoogleFitService().getBloodGlucose(accessToken, 'daily'));
      case 'weekly':
        return _generateWeeklyData(await GoogleFitService().getBloodGlucose(accessToken, 'weekly'));
      case 'monthly':
        return _generateMonthlyData(await GoogleFitService().getBloodGlucose(accessToken, 'monthly'));
      default:
        return [];
    }
  }


  List<FlSpot> _generateHourlyData(dynamic value) {
    if (value == null || value == "No Data") return [];

    final parsedValue = double.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final now = DateTime.now();

    return List.generate(24, (hour) {
      return FlSpot(
        hour.toDouble(),
        hour == now.hour ? parsedValue : 0,
      );
    });
  }


  List<FlSpot> _generateWeeklyData(dynamic value) {
    if (value == null || value == "No Data") return [];

    return [
      FlSpot(0, 0), // Sunday
      FlSpot(1, 0), // Monday
      FlSpot(2, 0), // Tuesday
      FlSpot(3, 0), // Wednesday
      FlSpot(4, 0), // Thursday
      FlSpot(5, 0), // Friday
      FlSpot(6, double.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0, // Saturday
      )];
  }

  List<FlSpot> _generateMonthlyData(dynamic value) {
    if (value == null || value == "No Data") return [];

    return List.generate(4, (week) {
      return FlSpot(
        week.toDouble(),
        week == 3 ? double.tryParse(value.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0: 0,
      );
    });
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 300, // Fixed height for square chart
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_chart_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Colors.pinkAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (_selectedPeriod == 'daily') {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('${value.toInt()}h'),
                    );
                  } else if (_selectedPeriod == 'weekly') {
                    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt()]),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('W${value.toInt() + 1}'),
                    );
                  }
                },
                reservedSize: 24,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: _calculateYAxisInterval(maxY),
                getTitlesWidget: (value, meta) {
                  // Format large numbers with K for thousands
                  if (value >= 1000) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(value.toInt().toString()),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: _calculateYAxisInterval(maxY),
            verticalInterval: _selectedPeriod == 'daily' ? 3 : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  double _calculateYAxisInterval(double maxY) {
    if (maxY > 10000) return 2000;
    if (maxY > 5000) return 1000;
    if (maxY > 1000) return 500;
    if (maxY > 500) return 100;
    if (maxY > 100) return 50;
    if (maxY > 50) return 10;
    return 5;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPeriod = newValue!;
                  fetchData();
                });
              },
              items: _periods
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e.capitalize(),
                  style: const TextStyle(color: Colors.black),
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoading)
              Container(
                height: 300,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            else if (hasError || chartData.isEmpty)
              Column(
                children: [
                  _buildEmptyChart(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              )
            else
              _buildChart(),

          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}


