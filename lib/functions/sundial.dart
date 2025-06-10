import 'package:flutter/material.dart';

import 'package:sundial/classes/sundial.dart';

int minutifyTimeOfDay(TimeOfDay? t) {
  if (t == null) return 0;
  return t.hour * 60 + t.minute;
}

bool shouldDivideTask(TimeOfDay? previousTaskTime, TimeOfDay? currentTaskTime, TimeOfDay dividerTime) {
  final int previousMinutes = minutifyTimeOfDay(previousTaskTime);
  final int currentMinutes = minutifyTimeOfDay(currentTaskTime);
  final int dividerMinutes = minutifyTimeOfDay(dividerTime);

  
  if (previousTaskTime == null && currentTaskTime != null && currentMinutes >= dividerMinutes) {
    return true;
  }

  
  return previousTaskTime != null && currentTaskTime != null &&
         previousMinutes < dividerMinutes &&
         currentMinutes >= dividerMinutes;
}
