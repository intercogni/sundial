import 'package:objectbox/objectbox.dart';
import 'dart:convert'; // For JSON encoding/decoding

// Define RepeatType enum for ObjectBox compatibility
enum RepeatType {
  none,
  daily,
  weekly,
}

// Define RepeatOptions class for ObjectBox compatibility
// This will be stored as a String (JSON) in the Task entity
class RepeatOptions {
  final RepeatType type;
  final List<int> selectedDays; // 1 for Monday, 7 for Sunday

  RepeatOptions({
    required this.type,
    this.selectedDays = const [],
  });

  // Convert RepeatOptions to a JSON string
  String toJson() {
    return jsonEncode({
      'type': type.index, // Store enum index
      'selectedDays': selectedDays,
    });
  }

  // Create RepeatOptions from a JSON string
  static RepeatOptions fromJson(String jsonString) {
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return RepeatOptions(
      type: RepeatType.values[map['type'] as int],
      selectedDays: List<int>.from(map['selectedDays'] as List),
    );
  }
}

@Entity()
class Task {
  int id;
  String title;
  String description;

  @Property(type: PropertyType.date) // Store as milliseconds since epoch
  DateTime dueDate;

  bool isCompleted;

  // For fixed time tasks
  int? timeInMinutes; // Store TimeOfDay as total minutes from midnight

  // For relative time tasks
  bool isRelative;
  String? solarEvent;
  int? offsetMinutes;

  // For repeat options
  String? repeatOptionsJson; // Store RepeatOptions as JSON string

  Task({
    this.id = 0,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.timeInMinutes,
    this.isRelative = false,
    this.solarEvent,
    this.offsetMinutes,
    RepeatOptions? repeatOptions, // Use a nullable parameter for RepeatOptions
  }) {
    // Convert RepeatOptions object to JSON string for storage
    if (repeatOptions != null) {
      repeatOptionsJson = repeatOptions.toJson();
    }
  }

  // Helper to get RepeatOptions object from stored JSON string
  RepeatOptions? get repeatOptions {
    if (repeatOptionsJson == null) return null;
    return RepeatOptions.fromJson(repeatOptionsJson!);
  }
}
