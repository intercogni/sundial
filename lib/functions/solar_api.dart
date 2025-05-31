import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SolarApi {
  static Future<Map<String, dynamic>?> fetchSolar(
    double latitude,
    double longitude,
  ) async {
    log('Request sunrise-sunset for lat=$latitude, lng=$longitude');
    return compute(_fetchSolar, {'latitude': latitude, 'longitude': longitude});
  }
}

Future<Map<String, dynamic>?> _fetchSolar(Map<String, dynamic> params) async {
  final double latitude = params['latitude'];
  final double longitude = params['longitude'];
  final String apiUrl =
      'https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude&formatted=0';
  try {
    log("HTTP ask");
    final response = await http.get(Uri.parse(apiUrl));
    log('Response status code: ${response.statusCode}');
    log('Response headers: ${response.headers}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('Raw response body: ${response.body}');
      if (data['status'] != 'OK') {
        log('API returned an error status: ${data['status']}');
        return null;
      }
      final results = data['results'];
      final Map<String, DateTime> solarEvents = {};
      for (final key in results.keys) {
        final value = results[key];
        if (value is String && value.isNotEmpty) {
          try {
            final parsedTime = DateTime.parse(value).toLocal();
            solarEvents[key] = parsedTime;
            log("Parsed [$key]: $parsedTime");
          } catch (e) {
            log("Failed to parse [$key]: $value. Error: $e");
          }
        }
      }
      log("Solar event map: $solarEvents");
      return {'results': results, 'parsed': solarEvents};
    } else {
      log("Failed to fetch data: ${response.statusCode}. Response body: ${response.body}");
      return null;
    }
  } catch (e) {
    log("Error fetching solar data: $e");
    return null;
  }
}
