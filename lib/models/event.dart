import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Event {
  @Id()
  int id = 0;
  String title;
  String? note;
  String timeStart;
  String timeEnd;
  String dateStart;
  String dateEnd;

  @Transient()
  TimeOfDay? startTime;
  @Transient()
  TimeOfDay? endTime;
  @Transient()
  DateTime? startDate;
  @Transient()
  DateTime? endDate;

  Event({
    required this.title,
    this.note,
    required this.timeStart,
    required this.timeEnd,
    required this.dateStart,
    required this.dateEnd,
  });

  static Event create({
    required String title,
    String? description,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return Event(
      title: title,
      note: description,
      timeStart: '${startTime.hour}:${startTime.minute}',
      timeEnd: '${endTime.hour}:${endTime.minute}',
      dateStart: startDate.toIso8601String(),
      dateEnd: endDate.toIso8601String(),
    )..restoreTimes();
  }

  void restoreTimes() {
    final partsStart = timeStart.split(':');
    final partsEnd = timeEnd.split(':');
    startTime = TimeOfDay(
      hour: int.parse(partsStart[0]),
      minute: int.parse(partsStart[1]),
    );
    endTime = TimeOfDay(
      hour: int.parse(partsEnd[0]),
      minute: int.parse(partsEnd[1]),
    );
    startDate = DateTime.parse(dateStart);
    endDate = DateTime.parse(dateEnd);
  }
}
