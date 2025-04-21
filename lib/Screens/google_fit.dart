import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleFitService {
  static const String webClientId = '728540480613-h65fhbl585gafbh11m37mos1c3bo5qht.apps.googleusercontent.com';
  static const String andClientId = "728540480613-dp8rf4nc2eq3tvpbd3akimqm11746c0m.apps.googleusercontent.com";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/fitness.activity.read',
      'https://www.googleapis.com/auth/fitness.body.read',
      'https://www.googleapis.com/auth/fitness.location.read',
      'https://www.googleapis.com/auth/fitness.blood_pressure.read',
      'https://www.googleapis.com/auth/fitness.blood_glucose.read',
      'https://www.googleapis.com/auth/fitness.oxygen_saturation.read',
      'https://www.googleapis.com/auth/fitness.body_temperature.read',
      'https://www.googleapis.com/auth/fitness.nutrition.read',
    ],
    signInOption: SignInOption.standard,
    clientId: andClientId,
    serverClientId: webClientId,
  );

  Future<String?> getAccessToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    return auth.accessToken;
  }

  Future<Map<String, dynamic>> _fetchMetric({
    required String accessToken,
    required String dataTypeName,
    required DateTime startTime,
    required DateTime endTime,
    required int bucketMillis,
  }) async {
    final url = Uri.parse(
      'https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'aggregateBy': [
          {'dataTypeName': dataTypeName}
        ],
        'bucketByTime': {'durationMillis': bucketMillis},
        'startTimeMillis': startTime.millisecondsSinceEpoch,
        'endTimeMillis': endTime.millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load $dataTypeName: ${response.body}');
    }
  }

  Future<String> getSteps(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start =DateTime.utc(now.year, now.month, now.day);
    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.step_count.delta',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num totalSteps = 0;
    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        totalSteps = point['value'][0]['intVal'];
      }
    }
    return "$totalSteps Steps";
  }

  Future<String> getHeartRate(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.heart_minutes',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num total = 0;
    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        total = point['value'][0]['fpVal'];
      }
    }
    return "${(total).toStringAsFixed(1)} bpm";
  }

  Future<String> getBloodPressure(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.blood_pressure',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num systolic = 0, diastolic = 0;
    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        systolic = point['value'][5]['fpVal'];
        diastolic = point['value'][0]['fpVal'];
      }

    }

    return "${(systolic).toStringAsFixed(1)}/${(diastolic).toStringAsFixed(1)} mmHg";
  }

  Future<String> getBloodGlucose(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.blood_glucose',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num total = 0;

    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        total = point['value'][0]['fpVal'];
      }
    }
    return "${(total).toStringAsFixed(1)} mmol/L";
  }

  Future<String> getOxygenSaturation(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.oxygen_saturation',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num total = 0;

    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        total = point['value'][0]['fpVal'];
      }
    }
    return "${(total).toStringAsFixed(1)}%";
  }

  Future<String> getBodyTemperature(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.body.temperature',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num total = 0;
    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        total = point['value'][0]['fpVal'];
      }
    }
    return "${(total).toStringAsFixed(1)} °C";
  }

  Future<String> getCaloriesBurned(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);
    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.calories.expended',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num total = 0;
    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        total = point['value'][0]['fpVal'];
      }
    }
    return "${total.toStringAsFixed(1)} kcal";
  }

  Future<String> getDistance(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);

    final data = await _fetchMetric(
      accessToken: accessToken,
      dataTypeName: 'com.google.distance.delta',
      startTime: start,
      endTime: now,
      bucketMillis: Duration(days: 1).inMilliseconds,
    );

    num totalMeters = 0;
    for (var bucket in data['bucket']) {
      for (var point in bucket['dataset'][0]['point']) {
        totalMeters = point['value'][0]['fpVal'];
      }
    }

    num totalKm = totalMeters / 1000;
    return "${totalKm.toStringAsFixed(1)} km";
  }


  Future<String> getSleepData(String accessToken) async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, now.day);

    final url = Uri.parse(
      'https://www.googleapis.com/fitness/v1/users/me/sessions'
          '?startTime=${start.toIso8601String()}'
          '&endTime=${now.toIso8601String()}'
          '&activityType=72',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Duration totalSleep = Duration.zero;

      if (data['session'] != null) {
        for (var session in data['session']) {
          final startMillis = int.parse(session['startTimeMillis']);
          final endMillis = int.parse(session['endTimeMillis']);
          totalSleep = Duration(milliseconds: endMillis - startMillis);
        }
        return '${totalSleep.inHours}h ${totalSleep.inMinutes % 60}m';
      }
      return 'No Data';
    } else {
      return 'Failed to load sleep data';
    }
  }
}
