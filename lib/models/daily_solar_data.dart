import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailySolarData {
  String? id;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String userId;
  final TimeOfDay? sunrise;
  final TimeOfDay? sunset;
  final TimeOfDay? solarNoon;
  final TimeOfDay? astronomicalTwilightBegin;
  final TimeOfDay? astronomicalTwilightEnd;
  final TimeOfDay? nauticalTwilightBegin;
  final TimeOfDay? nauticalTwilightEnd;

  DailySolarData({
    this.id,
    required this.date,
    required this.latitude,
    required this.longitude,
    this.locationName,
    required this.userId,
    this.sunrise,
    this.sunset,
    this.solarNoon,
    this.astronomicalTwilightBegin,
    this.astronomicalTwilightEnd,
    this.nauticalTwilightBegin,
    this.nauticalTwilightEnd,
  });

  factory DailySolarData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return DailySolarData(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      latitude: data['latitude'],
      longitude: data['longitude'],
      locationName: data['locationName'],
      userId: data['userId'] ?? 'defaultUserId',
      sunrise: _timeOfDayFromMap(data['sunrise']),
      sunset: _timeOfDayFromMap(data['sunset']),
      solarNoon: _timeOfDayFromMap(data['solarNoon']),
      astronomicalTwilightBegin: _timeOfDayFromMap(data['astronomicalTwilightBegin']),
      astronomicalTwilightEnd: _timeOfDayFromMap(data['astronomicalTwilightEnd']),
      nauticalTwilightBegin: _timeOfDayFromMap(data['nauticalTwilightBegin']),
      nauticalTwilightEnd: _timeOfDayFromMap(data['nauticalTwilightEnd']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'userId': userId,
      'sunrise': _timeOfDayToMap(sunrise),
      'sunset': _timeOfDayToMap(sunset),
      'solarNoon': _timeOfDayToMap(solarNoon),
      'astronomicalTwilightBegin': _timeOfDayToMap(astronomicalTwilightBegin),
      'astronomicalTwilightEnd': _timeOfDayToMap(astronomicalTwilightEnd),
      'nauticalTwilightBegin': _timeOfDayToMap(nauticalTwilightBegin),
      'nauticalTwilightEnd': _timeOfDayToMap(nauticalTwilightEnd),
    };
  }

  static TimeOfDay? _timeOfDayFromMap(Map? map) {
    if (map == null) return null;
    return TimeOfDay(hour: map['hour'], minute: map['minute']);
  }

  static Map? _timeOfDayToMap(TimeOfDay? time) {
    if (time == null) return null;
    return {'hour': time.hour, 'minute': time.minute};
  }
}
