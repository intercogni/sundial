import 'package:objectbox/objectbox.dart';
import 'dart:convert'; 


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
}

@Entity()
class Task {
  int id;
  String title;
  String description;

  @Property(type: PropertyType.date) 
  DateTime dueDate;

  bool isCompleted;

  
  int? timeInMinutes; 

  
  bool isRelative;
  String? solarEvent;
  int? offsetMinutes;

  
  String? repeatOptionsJson; 

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
    RepeatOptions? repeatOptions, 
  }) {
    
    if (repeatOptions != null) {
      repeatOptionsJson = repeatOptions.toJson();
    }
  }

  
  RepeatOptions? get repeatOptions {
    if (repeatOptionsJson == null) return null;
    return RepeatOptions.fromJson(repeatOptionsJson!);
  }
}
