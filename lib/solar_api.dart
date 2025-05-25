import 'dart:convert';
import 'package:http/http.dart' as http;

class SolarApi {
  static Future<Map<String, dynamic>?> fetchSunriseSunset(
    double latitude,
    double longitude,
  ) async {
    final String apiUrl =
        'https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude&formatted=0';
    print('Request sunrise-sunset for lat=$latitude, lng=$longitude');

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print("HTTP error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Fetch error: $e");
      return null;
    }
  }
}
