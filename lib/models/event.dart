import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String? id;
  String title;
  String? note;
  String timeStart;
  String timeEnd;
  String dateStart;
  String dateEnd;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime? startDate;
  DateTime? endDate;

  Event({
    this.id,
    required this.title,
    this.note,
    required this.timeStart,
    required this.timeEnd,
    required this.dateStart,
    required this.dateEnd,
  }) {
    restoreTimes();
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
      timeStart:
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      timeEnd:
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      dateStart: startDate.toIso8601String(),
      dateEnd: endDate.toIso8601String(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'note': note,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'dateStart': dateStart,
      'dateEnd': dateEnd,
    };
  }

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Event(
      id: snapshot.id,
      title: data['title'] ?? '',
      note: data['note'],
      timeStart: data['timeStart'],
      timeEnd: data['timeEnd'],
      dateStart: data['dateStart'],
      dateEnd: data['dateEnd'],
    );
  }
}
