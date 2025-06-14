import 'dart:convert';
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
    this.selectedDays = const [],
  });

  String toJson() {
    return jsonEncode({
      'type': type.index,
      'selectedDays': selectedDays,
    });
  }

  static RepeatOptions fromJson(String jsonString) {
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return RepeatOptions(
      type: RepeatType.values[map['type'] as int],
      selectedDays: List<int>.from(map['selectedDays'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'selectedDays': selectedDays,
    };
  }

  factory RepeatOptions.fromMap(Map<String, dynamic> map) {
    return RepeatOptions(
      type: RepeatType.values[map['type'] as int],
      selectedDays: List<int>.from(map['selectedDays'] as List),
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

  Task({
    this.id, 
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.timeInMinutes,
    this.isRelative = false,
    this.solarEvent,
    this.offsetMinutes,
    this.repeatOptions, 
  });

  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate), 
      'isCompleted': isCompleted,
      'timeInMinutes': timeInMinutes,
      'isRelative': isRelative,
      'solarEvent': solarEvent,
      'offsetMinutes': offsetMinutes,
      'repeatOptions': repeatOptions?.toMap(), 
    };
  }

  
  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Task(
      id: snapshot.id, 
      title: data['title'] as String,
      description: data['description'] as String,
      dueDate: (data['dueDate'] as Timestamp).toDate(), 
      isCompleted: data['isCompleted'] as bool,
      timeInMinutes: data['timeInMinutes'] as int?,
      isRelative: data['isRelative'] as bool,
      solarEvent: data['solarEvent'] as String?,
      offsetMinutes: data['offsetMinutes'] as int?,
      repeatOptions: data['repeatOptions'] != null
          ? RepeatOptions.fromMap(data['repeatOptions'] as Map<String, dynamic>)
          : null,
    );
  }
}
