import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_management/Authentication/Backend.dart';
import 'package:health_management/Authentication/auth_services.dart';

class ActivityPage extends StatefulWidget {
  final String title;

  const ActivityPage({super.key, required this.title});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _selectedPeriod = 'daily';
  final List<String> _periods = ['daily', 'weekly', 'monthly'];
  List<FlSpot> chartData = [];
  bool isLoading = true;
  bool hasError = false;
  double minY = 0;
  double maxY = 100;
  double? _maxDataValue;
  String userId = "";
  String dataType = "";
  List<Map<String, dynamic>> healthDataFromDB = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _loadUserData();
    await fetchData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final userInfo = await authService.getUserData();
    if (userInfo != null) {
      setState(() {
        userId = userInfo['user_id']?.toString() ?? '';
      });
    }
  }

  Future<void> fetchHealthData(String data) async {
    final db = DBHelper();
    healthDataFromDB = await db.getHealthData(data, userId);
    setState(() {
      dataType = data;
    });
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });
      String val = "value";

      switch (widget.title) {
        case 'Steps Taken':
          await fetchHealthData('StepsTaken');
          val = "steps";
          break;
        case 'Heart Rate':
          await fetchHealthData('HeartRate');
          val ="value";
          break;
        case 'Calories Burned':
          await fetchHealthData('CaloriesBurned');
          val ="calories";
          break;
        case 'BP Level':
          await fetchHealthData('BPLevel');
          val ="systolic";
          break;
        case 'SpO2 Level':
          await fetchHealthData('SpO2Level');
          val ="percentage";
          break;
        case 'Sleep Quality':
          await fetchHealthData('SleepQuality');
          val ="quality";
          break;
        case 'Body Temperature':
          await fetchHealthData('BodyTemperature');
          val ="value";
          break;
        case 'Distance Travelled':
          await fetchHealthData('DistanceTravelled');
          val ="distance";
          break;
        case 'Blood Glucose':
          await fetchHealthData('BloodGlucose');
          val ="glucose";
          break;
        default:
          healthDataFromDB = [];
      }
      // Process data based on selected period
      if (healthDataFromDB.isNotEmpty) {
        switch (_selectedPeriod) {
          case 'daily':
            chartData = _generateDailyData(val);
            break;
          case 'weekly':
            chartData = _generateWeeklyData(val);
            break;
          case 'monthly':
            chartData = _generateMonthlyData(val);
            break;
        }
      } else {
        chartData = [];
      }
      // Calculate max Y value for the chart
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

  // Update the _parseNumber method to handle "3040 Steps" format
  double _parseNumber(dynamic value) {
    if (value == null) return 0.0;

    if (value is int) return value.toDouble();
    if (value is double) return value;

    // Handle string values like "3040 Steps"
    if (value is String) {
      // Extract the numeric part from strings like "3040 Steps"
      final numericPart = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(numericPart) ?? 0.0;
    }
    return 0.0;
  }

// Update the _generateDailyData method to properly group data
  List<FlSpot> _generateDailyData(String val) {
    if (healthDataFromDB.isEmpty) return [];

    final now = DateTime.now();

    // Store latest entry per 3-hour bucket
    Map<int, Map<String, dynamic>> latestPerBucket = {};

    for (var entry in healthDataFromDB) {
      final entryDate = DateTime.parse(entry['date']);

      if (entryDate.year == now.year &&
          entryDate.month == now.month &&
          entryDate.day == now.day) {

        int hour;

        if (entry.containsKey("time") && entry["time"] != null) {
          final timeParts = entry["time"].toString().split(":");
          hour = int.tryParse(timeParts[0]) ?? entryDate.hour;
        } else {
          hour = entryDate.hour;
        }

        final bucketIndex = (hour / 3).floor().clamp(0, 7);

        // Overwrite to keep latest value
        latestPerBucket[bucketIndex] = entry;
      }
    }

    // Generate 8 FlSpots for each 3-hour bucket (0, 3, 6,..., 21)
    List<FlSpot> spots = [];

    for (int i = 0; i < 8; i++) {
      if (latestPerBucket.containsKey(i)) {
        final entry = latestPerBucket[i]!;
        final value = _parseNumber(entry[val]);
        spots.add(FlSpot(i * 3.0, value));
      } else {
        spots.add(FlSpot(i * 3.0, 0)); // Show 0 when no data
      }
    }

    return spots;
  }

  List<FlSpot> _generateWeeklyData(String val) {
    if (healthDataFromDB.isEmpty) return [];

    final now = DateTime.now();
    // Map weekday index (0=Sun … 6=Sat) → the latest DB entry for that day
    final Map<int, Map<String, dynamic>> latestPerDay = {};

    for (var entry in healthDataFromDB) {
      final entryDate = DateTime.parse(entry['date']);
      if (_isSameWeek(entryDate, now)) {
        // Map Dart's weekday (Mon=1…Sun=7) into your 0–6 where 0=Sunday
        final int dayIndex = entryDate.weekday % 7;
        // Overwrite so the last one in the loop "wins" as the latest for that day
        latestPerDay[dayIndex] = entry;
      }
    }

    // Build exactly 7 spots
    return List.generate(7, (i) {
      if (latestPerDay.containsKey(i)) {
        final entry = latestPerDay[i]!;
        final y = _parseNumber(entry[val]);
        return FlSpot(i.toDouble(), y);
      } else {
        return FlSpot(i.toDouble(), 0);
      }
    });
  }

  List<FlSpot> _generateMonthlyData(String val) {
    if (healthDataFromDB.isEmpty) return [];

    final now = DateTime.now();
    // Map weekIndex (0=days 1–7, 1=8–14, 2=15–21, 3=22–end) → latest entry
    final Map<int, Map<String, dynamic>> latestPerWeek = {};

    for (var entry in healthDataFromDB) {
      final entryDate = DateTime.parse(entry['date']);
      if (entryDate.year == now.year && entryDate.month == now.month) {
        final weekIndex = ((entryDate.day - 1) / 7).floor().clamp(0, 3);
        // overwrite so the last loop iteration wins as the “latest” for that week
        latestPerWeek[weekIndex] = entry;
      }
    }

    // Build exactly 4 spots: x=0,1,2,3 for Week 1–4
    return List.generate(4, (i) {
      if (latestPerWeek.containsKey(i)) {
        final entry = latestPerWeek[i]!;
        final y = _parseNumber(entry[val]);
        return FlSpot(i.toDouble(), y);
      } else {
        return FlSpot(i.toDouble(), 0);
      }
    });
  }


  bool _isSameWeek(DateTime a, DateTime b) {
    // Adjust dates to the start of the week (Sunday)
    final aStart = a.subtract(Duration(days: a.weekday % 7));
    final bStart = b.subtract(Duration(days: b.weekday % 7));
    return aStart.year == bStart.year && aStart.month == bStart.month && aStart.day == bStart.day;
  }

  double _calculateOptimalMaxY(double maxValue) {
    if (maxValue <= 0) return 100; // Default fallback

    // For values in thousands
    if (maxValue > 1000) {
      return (maxValue * 1.2).ceilToDouble();
    }
    // For values in hundreds
    else if (maxValue > 100) {
      return (maxValue * 1.2).ceilToDouble() / 10 * 10;
    }
    // For smaller values
    else {
      return (maxValue * 1.2).ceilToDouble();
    }
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 300,
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
      child: BarChart(
        BarChartData(
          barGroups: chartData.map((spot) {
            return BarChartGroupData(
              x: spot.x.toInt(),
              barRods: [
                BarChartRodData(
                  toY: spot.y,
                  color: Colors.pinkAccent,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
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
            drawHorizontalLine: true,
            horizontalInterval: _calculateYAxisInterval(maxY),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          minY: minY,
          maxY: maxY,
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