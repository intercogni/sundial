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
          border: Border.all(
            width: 1.5,
            color: Colors.white.withOpacity(0.2),
          ),
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
                  padding: const EdgeInsets.all(20),
                  child: Glassmorphism(
                    blur: 10,
                    opacity: 0.2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
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

                  final dividers = <Widget>[];

                  if (shouldDivideTask(tasks, index, solarData.astronomicalTwilightBegin!)) {
                    dividers.add(SundialDivider(time: solarData.astronomicalTwilightBegin!, label: 'first light'));
                  }
                  if (shouldDivideTask(tasks, index, solarData.nauticalTwilightBegin!)) {
                    dividers.add(SundialDivider(time: solarData.nauticalTwilightBegin!, label: 'dusk'));
                  }
                  // if (shouldDivideTask(tasks, index, solarData.civilTwilightBegin!)) {
                  //   dividers.add(SundialDivider(time: solarData.civilTwilightBegin!, label: 'Dusk'));
                  // }
                  if (shouldDivideTask(tasks, index, solarData.sunrise!)) {
                    dividers.add(SundialDivider(time: solarData.sunrise!, label: 'sunrise'));
                  }
                  if (shouldDivideTask(tasks, index, solarData.solarNoon!)) {
                    dividers.add(SundialDivider(time: solarData.solarNoon!, label: 'noon'));
                  }
                  if (shouldDivideTask(tasks, index, solarData.sunset!)) {
                    dividers.add(SundialDivider(time: solarData.sunset!, label: 'sunset'));
                  }
                  // if (shouldDivideTask(tasks, index, solarData.civilTwilightEnd!)) {
                  //   dividers.add(SundialDivider(time: solarData.civilTwilightEnd!, label: 'Dawn Ends'));
                  // }
                  if (shouldDivideTask(tasks, index, solarData.nauticalTwilightEnd!)) {
                    dividers.add(SundialDivider(time: solarData.nauticalTwilightEnd!, label: 'last light'));
                  }
                  if (shouldDivideTask(tasks, index, solarData.astronomicalTwilightEnd!)) {
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
                        ListTile(
                          title: Text(
                            task.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${task.description} - $timeText',
                            style: const TextStyle(color: Colors.white70),
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
                          backgroundColor: Colors.green.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                        child: Text(
                          time == null ? 'Select Time' : time!.format(context),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (isRelative)
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
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
                            style: const TextStyle(color: Colors.white),
                            value: solarEvent,
                            items: ['first light', 'dusk', 'sunrise', 'noon', 'sunset', 'last light', 'night']
                                .map((event) => DropdownMenuItem(value: event, child: Text(event, style: const TextStyle(color: Colors.white)))) // Dropdown item text color
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                solarEvent = value;
                              });
                            },
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
                    if (!isRelative && time != null) {
                      _addTask(
                        Task(title: title, description: description, time: time!),
                      );
                      Navigator.pop(context);
                    } else if (isRelative && solarEvent != null && offsetMinutes != null) {
                      _addTask(
                        Task(title: title, description: description, isRelative: true, solarEvent: solarEvent, offsetMinutes: offsetMinutes),
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
                          backgroundColor: Colors.green.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                        child: Text(
                          time == null ? 'Select Time' : time!.format(context),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (isRelative)
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
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
                            style: const TextStyle(color: Colors.white),
                            value: solarEvent,
                            items: ['sunrise', 'sunset', 'solarNoon', 'astronomicalTwilightBegin', 'nauticalTwilightBegin', 'civilTwilightBegin', 'civilTwilightEnd', 'nauticalTwilightEnd', 'astronomicalTwilightEnd']
                                .map((event) => DropdownMenuItem(value: event, child: Text(event, style: const TextStyle(color: Colors.black))))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                solarEvent = value;
                              });
                            },
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
                    if (!isRelative && time != null) {
                      _updateTask(
                        index,
                        Task(title: title, description: description, time: time!),
                      );
                      Navigator.pop(context);
                    } else if (isRelative && solarEvent != null && offsetMinutes != null) {
                      _updateTask(
                        index,
                        Task(title: title, description: description, isRelative: true, solarEvent: solarEvent, offsetMinutes: offsetMinutes),
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
