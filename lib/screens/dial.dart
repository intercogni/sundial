import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/solar_data.dart';
import 'package:sundial/widgets/sundial_divider.dart';

import 'package:sundial/classes/sundial.dart';
import 'package:sundial/functions/sundial.dart';
import 'dart:ui';

class Glassmorphism extends StatelessWidget {
  final double blur;
  final double opacity;
  final Widget child;

  const Glassmorphism({
    Key? key,
    required this.blur,
    required this.opacity,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}

class DialScreen extends StatefulWidget {
  const DialScreen({Key? key}) : super(key: key);

  @override
  State<DialScreen> createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  List<Task> tasks = [];

  // Helper function to get the absolute TimeOfDay for a task
  TimeOfDay? _getTaskTime(Task task, SolarData solarData) {
    if (!task.isRelative) {
      return task.time;
    }

    if (task.solarEvent == null || task.offsetMinutes == null) {
      return null; // Should not happen if task is created correctly
    }

    TimeOfDay? solarEventTime;
    switch (task.solarEvent) {
      case 'first light':
        solarEventTime = solarData.astronomicalTwilightBegin;
        break;
      case 'dusk':
        solarEventTime = solarData.nauticalTwilightBegin;
        break;
      case 'sunrise':
        solarEventTime = solarData.sunrise;
        break;
      case 'noon':
        solarEventTime = solarData.solarNoon;
        break;
      case 'sunset':
        solarEventTime = solarData.sunset;
        break;
      case 'last light':
        solarEventTime = solarData.nauticalTwilightEnd;
        break;
      case 'night':
        solarEventTime = solarData.astronomicalTwilightEnd;
        break;
      default:
        return null; // Unknown solar event
    }

    if (solarEventTime == null) {
      return null; // Solar event time not available
    }

    // Calculate the time with offset
    final totalMinutes = solarEventTime.hour * 60 + solarEventTime.minute + task.offsetMinutes!;
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;

    // Handle time wrapping around midnight
    return TimeOfDay(hour: hour % 24, minute: minute);
  }

  void _sortTasks(SolarData solarData) {
    tasks.sort((a, b) {
      final timeA = _getTaskTime(a, solarData);
      final timeB = _getTaskTime(b, solarData);

      if (timeA == null && timeB == null) {
        return 0; // Keep original order if both are null
      } else if (timeA == null) {
        return 1; // Nulls go to the end
      } else if (timeB == null) {
        return -1; // Nulls go to the end
      } else {
        return timeA.compareTo(timeB);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    tasks.add(Task(
      title: '--', 
      description: '--', 
      time: const TimeOfDay(
        hour: 23, minute: 59)));
    // Initial sort (will be updated in build)
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      // Sorting is now handled in build
    });
  }

  void _updateTask(int index, Task task) {
    setState(() {
      tasks[index] = task;
      // Sorting is now handled in build
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  String _formatRepeatOptions(RepeatOptions repeatOptions) {
    switch (repeatOptions.type) {
      case RepeatType.daily:
        return 'Repeats Daily';
      case RepeatType.weekly:
        final days = repeatOptions.selectedDays.map((day) {
          return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
        }).join(', ');
        return 'Repeats Weekly on: $days';
      case RepeatType.none:
        return 'Does not repeat';
      default:
        return 'Unknown repeat type'; // Handle any unhandled cases
    }
  }

  @override
  Widget build(BuildContext context) {
    final solarData = Provider.of<SolarData>(context);
    _sortTasks(solarData); // Sort tasks whenever solar data changes

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF13162B),
              Color(0xFF3A4058),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        _showAddDialog(context);
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      child: ListView.builder(
                        shrinkWrap: true, // Important for nested ListView
                        physics: const NeverScrollableScrollPhysics(), // Disable scrolling for nested ListView
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          if (index >= tasks.length) {
                            return const SizedBox.shrink();
                          }

                  final task = tasks[index];
                  final taskTime = _getTaskTime(task, solarData);
                  final previousTaskTime = index > 0 ? _getTaskTime(tasks[index - 1], solarData) : null;

                  final dividers = <Widget>[];

                  if (shouldDivideTask(previousTaskTime, taskTime, solarData.astronomicalTwilightBegin!)) {
                    dividers.add(SundialDivider(time: solarData.astronomicalTwilightBegin!, label: 'first light'));
                  }
                  if (shouldDivideTask(previousTaskTime, taskTime, solarData.nauticalTwilightBegin!)) {
                    dividers.add(SundialDivider(time: solarData.nauticalTwilightBegin!, label: 'dusk'));
                  }
                  // if (shouldDivideTask(previousTaskTime, taskTime, solarData.civilTwilightBegin!)) {
                  //   dividers.add(SundialDivider(time: solarData.civilTwilightBegin!, label: 'Dusk'));
                  // }
                  if (shouldDivideTask(previousTaskTime, taskTime, solarData.sunrise!)) {
                    dividers.add(SundialDivider(time: solarData.sunrise!, label: 'sunrise'));
                  }
                  if (shouldDivideTask(previousTaskTime, taskTime, solarData.solarNoon!)) {
                    dividers.add(SundialDivider(time: solarData.solarNoon!, label: 'noon'));
                  }
                  if (shouldDivideTask(previousTaskTime, taskTime, solarData.sunset!)) {
                    dividers.add(SundialDivider(time: solarData.sunset!, label: 'sunset'));
                  }
                  // if (shouldDivideTask(previousTaskTime, taskTime, solarData.civilTwilightEnd!)) {
                  //   dividers.add(SundialDivider(time: solarData.civilTwilightEnd!, label: 'Dawn Ends'));
                  // }
                  if (shouldDivideTask(previousTaskTime, taskTime, solarData.nauticalTwilightEnd!)) {
                    dividers.add(SundialDivider(time: solarData.nauticalTwilightEnd!, label: 'last light'));
                  }
                  if (shouldDivideTask(previousTaskTime, taskTime, solarData.astronomicalTwilightEnd!)) {
                    dividers.add(SundialDivider(time: solarData.astronomicalTwilightEnd!, label: 'night'));
                  }

                  Widget? divider;
                  if (dividers.isNotEmpty) {
                    divider = Column(children: dividers);
                  }

                  String timeText;
                  if (task.isRelative) {
                    String offsetSign = task.offsetMinutes! >= 0 ? 'after' : 'before';
                    int absoluteOffset = task.offsetMinutes!.abs();
                    timeText = '$absoluteOffset minutes $offsetSign ${task.solarEvent}';
                  } else {
                    timeText = taskTime?.format(context) ?? '--:--';
                  }


                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (divider != null) divider,
                      if (index == tasks.length - 1)
                        const SizedBox.shrink()
                      else
                        Container(
                          margin: const EdgeInsets.only(bottom: 10), // Add margin between tasks
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1), // Slightly opaque background for the task item
                            borderRadius: BorderRadius.circular(15), // Rounded corners for the task item
                            border: Border.all(
                              width: 1.5,
                              color: Colors.white.withOpacity(0.2), // Border for the task item
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              task.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${MaterialLocalizations.of(context).formatTimeOfDay(taskTime ?? TimeOfDay.now(), alwaysUse24HourFormat: true)} - $timeText',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  task.description,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                                ),
                                if (task.repeatOptions != null && task.repeatOptions!.type != RepeatType.none)
                                  Text(
                                    _formatRepeatOptions(task.repeatOptions!),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'update',
                                  child: Text(
                                    'Update',
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'update') {
                                  _showUpdateDialog(context, index);
                                } else if (value == 'delete') {
                                  _deleteTask(index);
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    String title = '';
    String description = '';
    TimeOfDay? time;
    bool isRelative = false;
    String? solarEvent;
    int? offsetMinutes;
    RepeatType repeatType = RepeatType.none;
    List<int> selectedDays = []; // 1 for Monday, 7 for Sunday

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.1), // Semi-transparent background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                width: 1.5,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            title: const Text(
              'add task',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: ToggleButtons(
                        isSelected: [!isRelative, isRelative],
                        onPressed: (int index) {
                          setState(() {
                            isRelative = index == 1;
                          });
                        },
                        color: Colors.white, // Text color for unselected
                        selectedColor: Colors.white, // Text color for selected
                        fillColor: Colors.white.withOpacity(0.3), // Background color for selected
                        borderColor: Colors.white.withOpacity(0.5), // Border color
                        selectedBorderColor: Colors.white, // Border color for selected
                        borderRadius: BorderRadius.circular(15.0),
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'fixed',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'relative',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'title',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'description',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (!isRelative)
                      ElevatedButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              time = selectedTime;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          time == null ? 'select time' : time!.format(context),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    if (isRelative)
                      Column(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              dropdownMenuTheme: DropdownMenuThemeData(
                                menuStyle: MenuStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15), // Apply rounded corners
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)), // Match dropdown background
                                ),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Solar Event',
                                labelStyle: const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                              dropdownColor: Colors.transparent, // Set to transparent as background is handled by MenuStyle
                              iconEnabledColor: Colors.white, // White icon
                              style: const TextStyle(color: Colors.white),
                              value: solarEvent,
                              items: ['first light', 'dusk', 'sunrise', 'noon', 'sunset', 'last light', 'night']
                                  .map((event) => DropdownMenuItem(
                                        value: event,
                                        child: Glassmorphism(
                                          blur: 5,
                                          opacity: 0.0,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            child: Text(event, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontSize: 16.0)),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  solarEvent = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Offset in Minutes',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              offsetMinutes = int.tryParse(value);
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Theme(
                      data: Theme.of(context).copyWith(
                        dropdownMenuTheme: DropdownMenuThemeData(
                          menuStyle: MenuStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15), // Apply rounded corners
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)), // Match dropdown background
                          ),
                        ),
                      ),
                      child: DropdownButtonFormField<RepeatType>(
                        decoration: InputDecoration(
                          labelText: 'Repeat',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.3),
                        ),
                        dropdownColor: Colors.transparent, // Set to transparent as background is handled by MenuStyle
                        iconEnabledColor: Colors.white, // White icon
                        style: const TextStyle(color: Colors.white),
                        value: repeatType,
                        items: RepeatType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Glassmorphism(
                                    blur: 5,
                                    opacity: 0.0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                                      child: Text(
                                        type.toString().split('.').last,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            repeatType = value!;
                            selectedDays = []; // Reset selected days when repeat type changes
                          });
                        },
                      ),
                    ),
                    if (repeatType == RepeatType.weekly)
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            children: List<Widget>.generate(7, (int index) {
                              final day = index + 1; // 1 for Monday, 7 for Sunday
                              final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                              return FilterChip(
                                label: Text(dayName),
                                selected: selectedDays.contains(day),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.removeWhere((element) => element == day);
                                    }
                                  });
                                },
                                selectedColor: Colors.green.shade300,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(color: selectedDays.contains(day) ? Colors.white : Colors.white70),
                                backgroundColor: Colors.white.withOpacity(0.3),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (title.isNotEmpty && description.isNotEmpty) {
                    RepeatOptions? finalRepeatOptions;
                    if (repeatType != RepeatType.none) {
                      finalRepeatOptions = RepeatOptions(type: repeatType, selectedDays: selectedDays);
                    }

                    if (!isRelative && time != null) {
                      _addTask(
                        Task(title: title, description: description, time: time!, repeatOptions: finalRepeatOptions),
                      );
                      Navigator.pop(context);
                    } else if (isRelative && solarEvent != null && offsetMinutes != null) {
                      _addTask(
                        Task(title: title, description: description, isRelative: true, solarEvent: solarEvent, offsetMinutes: offsetMinutes, repeatOptions: finalRepeatOptions),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showUpdateDialog(BuildContext context, int index) async {
    String title = tasks[index].title;
    String description = tasks[index].description;
    TimeOfDay? time = tasks[index].time;
    bool isRelative = tasks[index].isRelative;
    String? solarEvent = tasks[index].solarEvent;
    int? offsetMinutes = tasks[index].offsetMinutes;
    RepeatType repeatType = tasks[index].repeatOptions?.type ?? RepeatType.none;
    List<int> selectedDays = List.from(tasks[index].repeatOptions?.selectedDays ?? []);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.1), // Semi-transparent background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                width: 1.5,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            title: const Text(
              'update task',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'title',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        title = value;
                      },
                      controller: TextEditingController(text: title),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'description',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        description = value;
                      },
                      controller: TextEditingController(text: description),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: ToggleButtons(
                        isSelected: [!isRelative, isRelative],
                        onPressed: (int index) {
                          setState(() {
                            isRelative = index == 1;
                          });
                        },
                        color: Colors.white, // Text color for unselected
                        selectedColor: Colors.white, // Text color for selected
                        fillColor: Colors.white.withOpacity(0.3), // Background color for selected
                        borderColor: Colors.white.withOpacity(0.5), // Border color
                        selectedBorderColor: Colors.white, // Border color for selected
                        borderRadius: BorderRadius.circular(15.0),
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Fixed Time',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Relative Time',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!isRelative)
                      ElevatedButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: time ?? TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              time = selectedTime;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          time == null ? 'select time' : time!.format(context),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    if (isRelative)
                      Column(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              dropdownMenuTheme: DropdownMenuThemeData(
                                menuStyle: MenuStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15), // Apply rounded corners
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)), // Match dropdown background
                                ),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Solar Event',
                                labelStyle: const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                              dropdownColor: Colors.transparent, // Set to transparent as background is handled by MenuStyle
                              iconEnabledColor: Colors.white, // White icon
                              style: const TextStyle(color: Colors.white),
                              value: solarEvent,
                              items: ['first light', 'dusk', 'sunrise', 'noon', 'sunset', 'last light', 'night']
                                  .map((event) => DropdownMenuItem(
                                        value: event,
                                        child: Glassmorphism(
                                          blur: 5,
                                          opacity: 0.1,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            child: Text(event, style: const TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  solarEvent = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Offset in Minutes',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              offsetMinutes = int.tryParse(value);
                            },
                            controller: TextEditingController(text: offsetMinutes?.toString() ?? ''),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<RepeatType>(
                      decoration: InputDecoration(
                        labelText: 'Repeat',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                      ),
                      dropdownColor: Colors.white.withOpacity(0.1), // Glassmorphism background
                      iconEnabledColor: Colors.white, // White icon
                      style: const TextStyle(color: Colors.white),
                      value: repeatType,
                      items: RepeatType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Glassmorphism(
                                  blur: 5,
                                  opacity: 0.1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      type.toString().split('.').last,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          repeatType = value!;
                          selectedDays = []; // Reset selected days when repeat type changes
                        });
                      },
                    ),
                    if (repeatType == RepeatType.weekly)
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            children: List<Widget>.generate(7, (int index) {
                              final day = index + 1; // 1 for Monday, 7 for Sunday
                              final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                              return FilterChip(
                                label: Text(dayName),
                                selected: selectedDays.contains(day),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.removeWhere((element) => element == day);
                                    }
                                  });
                                },
                                selectedColor: Colors.green.shade300,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(color: selectedDays.contains(day) ? Colors.white : Colors.white70),
                                backgroundColor: Colors.white.withOpacity(0.3),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (title.isNotEmpty && description.isNotEmpty) {
                    RepeatOptions? finalRepeatOptions;
                    if (repeatType != RepeatType.none) {
                      finalRepeatOptions = RepeatOptions(type: repeatType, selectedDays: selectedDays);
                    }

                    if (!isRelative && time != null) {
                      _updateTask(
                        index,
                        Task(title: title, description: description, time: time!, repeatOptions: finalRepeatOptions),
                      );
                      Navigator.pop(context);
                    } else if (isRelative && solarEvent != null && offsetMinutes != null) {
                      _updateTask(
                        index,
                        Task(title: title, description: description, isRelative: true, solarEvent: solarEvent, offsetMinutes: offsetMinutes, repeatOptions: finalRepeatOptions),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
