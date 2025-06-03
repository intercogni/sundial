import 'package:flutter/material.dart';

class Task {
  final String title;
  final String description;
  final TimeOfDay? time; // Make time nullable
  final bool isRelative; // New property
  final String? solarEvent; // New property
  final int? offsetMinutes; // New property

  Task({
    required this.title,
    required this.description,
    this.time, // Make time optional
    this.isRelative = false, // Default to false
    this.solarEvent,
    this.offsetMinutes,
  });
}
