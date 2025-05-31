import 'package:flutter/material.dart';

import 'package:sundial/classes/sundial.dart';

int minutifyTimeOfDay(TimeOfDay? t) {
  if (t == null) return 0;
  return t.hour * 60 + t.minute;
}

bool shouldDivideTask(List<Task> tasks, int index, TimeOfDay time) {
  if (index == 0 && minutifyTimeOfDay(tasks[index].time) >= minutifyTimeOfDay(time)) {
    return true;
  }

  return index > 0 &&
    minutifyTimeOfDay(tasks[index - 1].time) < minutifyTimeOfDay(time) &&
    minutifyTimeOfDay(tasks[index].time) >= minutifyTimeOfDay(time);
}
