import 'dart:convert';
import 'package:health_management/Authentication/Backend.dart';
import 'package:http/http.dart' as http;

Future<String?> getFullModelPrediction(String userId) async {
  try {
    // All health tables with their value keys
    Map<String, String> tables = {
      'StepsTaken': 'steps',
      'HeartRate': 'value',
      'CaloriesBurned': 'calories',
      'BPLevel': 'systolic',
      'SpO2Level': 'percentage',
      'SleepQuality': 'quality',
      'BodyTemperature': 'value',
      'DistanceTravelled': 'distance',
      'BloodGlucose': 'glucose',
    };

    Map<String, List<double>> inputMap = {};
    for (var entry in tables.entries) {
      String table = entry.key;
      String key = entry.value;

      List<Map<String, dynamic>> healthData = await DBHelper().getHealthData(table, userId);

      List<double> values = healthData
          .map<double>((item) => double.tryParse(item[key].toString()) ?? 0.0)
          .toList();

      if (values.length > 5) {
        values = values.sublist(values.length - 5);
      }

      inputMap[table] = values;
    }

    // Send to model API
    final response = await http.post(
      Uri.parse("https://1234-abcde.ngrok.io/predict"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'input': inputMap}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['prediction'].toString();
    } else {
      print("API Error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}
