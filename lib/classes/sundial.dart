import 'package:flutter/material.dart';

enum RepeatType {
  none,
  daily,
  weekly,
}

class RepeatOptions {
  final RepeatType type;
  final List<int> selectedDays; // 1 for Monday, 7 for Sunday

  RepeatOptions({
    required this.type,
    this.selectedDays = const [],
  });
}

class Task {
  final String title;
  final String description;
  final TimeOfDay? time;
  final bool isRelative;
  final String? solarEvent;
  final int? offsetMinutes;
  final RepeatOptions? repeatOptions; // New property

  Task({
    required this.title,
    required this.description,
    this.time,
    this.isRelative = false,
    this.solarEvent,
    this.offsetMinutes,
    this.repeatOptions, // Make repeatOptions optional
  });
}
