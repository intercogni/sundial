import 'package:cloud_firestore/cloud_firestore.dart';

enum RepeatType {
  none,
  daily,
  weekly,
}

class RepeatOptions {
  final RepeatType type;
  final List<int> selectedDays;

  RepeatOptions({
    required this.type,
    required this.selectedDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'selectedDays': selectedDays,
    };
  }

  factory RepeatOptions.fromJson(Map<String, dynamic> json) {
    return RepeatOptions(
      type: RepeatType.values[json['type'] as int],
      selectedDays: List<int>.from(json['selectedDays'] as List),
    );
  }
}

class Task {
  String? id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  int? timeInMinutes;
  bool isRelative;
  String? solarEvent;
  int? offsetMinutes;
  RepeatOptions? repeatOptions;
  String? userId;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.timeInMinutes,
    this.isRelative = false,
    this.solarEvent,
    this.offsetMinutes,
    this.repeatOptions,
    this.userId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'timeInMinutes': timeInMinutes,
      'isRelative': isRelative,
      'solarEvent': solarEvent,
      'offsetMinutes': offsetMinutes,
      'repeatOptions': repeatOptions?.toJson(),
      'userId': userId,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      timeInMinutes: data['timeInMinutes'],
      isRelative: data['isRelative'] ?? false,
      solarEvent: data['solarEvent'],
      offsetMinutes: data['offsetMinutes'],
      repeatOptions: data['repeatOptions'] != null
          ? RepeatOptions.fromJson(data['repeatOptions'])
          : null,
      userId: data['userId'],
    );
  }
}
