import 'package:flutter/material.dart';
import 'package:sundial/functions/solar_api.dart';
import 'dart:developer';

class SolarData extends ChangeNotifier {
  TimeOfDay? _astronomicalTwilightBegin;
  TimeOfDay? _nauticalTwilightBegin;
  TimeOfDay? _civilTwilightBegin;
  TimeOfDay? _sunrise;
  TimeOfDay? _solarNoon;
  TimeOfDay? _sunset;
  TimeOfDay? _civilTwilightEnd;
  TimeOfDay? _nauticalTwilightEnd;
  TimeOfDay? _astronomicalTwilightEnd;

  SolarData() {
    _solarEvents();
  }

  TimeOfDay? get sunrise => _sunrise;
  TimeOfDay? get sunset => _sunset;
  TimeOfDay? get solarNoon => _solarNoon;
  TimeOfDay? get civilTwilightBegin => _civilTwilightBegin;
  TimeOfDay? get civilTwilightEnd => _civilTwilightEnd;
  TimeOfDay? get nauticalTwilightBegin => _nauticalTwilightBegin;
  TimeOfDay? get nauticalTwilightEnd => _nauticalTwilightEnd;
  TimeOfDay? get astronomicalTwilightBegin => _astronomicalTwilightBegin;
  TimeOfDay? get astronomicalTwilightEnd => _astronomicalTwilightEnd;

  Future<void> _solarEvents() async {
    log("Awaiting solar event data");
    final result = await SolarApi.fetchSunriseSunset(-7.2575, 112.7521);
    log("Notice from solar event data");
    if (result != null) {
      final results = result['results'];
      final sunriseUtc = DateTime.parse(results['sunrise']).toLocal();
      final sunsetUtc = DateTime.parse(results['sunset']).toLocal();
      final solarNoonUtc = DateTime.parse(results['solar_noon']).toLocal();
      final civilTwilightBeginUtc = DateTime.parse(results['civil_twilight_begin']).toLocal();
      final civilTwilightEndUtc = DateTime.parse(results['civil_twilight_end']).toLocal();
      final nauticalTwilightBeginUtc = DateTime.parse(results['nautical_twilight_begin']).toLocal();
      final nauticalTwilightEndUtc = DateTime.parse(results['nautical_twilight_end']).toLocal();
      final astronomicalTwilightBeginUtc = DateTime.parse(results['astronomical_twilight_begin']).toLocal();
      final astronomicalTwilightEndUtc = DateTime.parse(results['astronomical_twilight_end']).toLocal();

      _sunrise = TimeOfDay.fromDateTime(sunriseUtc);
      _sunset = TimeOfDay.fromDateTime(sunsetUtc);
      _solarNoon = TimeOfDay.fromDateTime(solarNoonUtc);
      _civilTwilightBegin = TimeOfDay.fromDateTime(civilTwilightBeginUtc);
      _civilTwilightEnd = TimeOfDay.fromDateTime(civilTwilightEndUtc);
      _nauticalTwilightBegin = TimeOfDay.fromDateTime(nauticalTwilightBeginUtc);
      _nauticalTwilightEnd = TimeOfDay.fromDateTime(nauticalTwilightEndUtc);
      _astronomicalTwilightBegin = TimeOfDay.fromDateTime(astronomicalTwilightBeginUtc);
      _astronomicalTwilightEnd = TimeOfDay.fromDateTime(astronomicalTwilightEndUtc);
      notifyListeners();
      log("Successfully fetched solar event data");
    } else {
      log("Failed to fetch solar event data");
    }
  }

  void updateSolarTimes({TimeOfDay? sunrise, TimeOfDay? sunset}) {
    _sunrise = sunrise;
    _sunset = sunset;
    notifyListeners();
  }
}
