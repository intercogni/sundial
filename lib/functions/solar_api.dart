import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SolarApi {
  static Future<Map<String, dynamic>?> fetchSunriseSunset(
    double latitude,
    double longitude,
  ) async {
    log('Request sunrise-sunset for lat=$latitude, lng=$longitude');
    return compute(_fetchSunriseSunset, {
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}

Future<Map<String, dynamic>?> _fetchSunriseSunset(
  Map<String, dynamic> params,
) async {
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
      log('Raw response body: ${response.body}');
      try {
        final data = json.decode(response.body);
        log("HTTP Success");
        return data;
      } catch (e) {
        log("JSON decoding error: $e");
        return null;
      }
    } else {
      log("HTTP error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    log("Fetch error: $e");
    return null;
  }
}
