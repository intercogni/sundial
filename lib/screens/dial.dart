import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/solar_data.dart';
import 'package:sundial/widgets/sundial_divider.dart';

import 'package:sundial/classes/sundial.dart';
import 'package:sundial/functions/sundial.dart';
import 'dart:ui';

class DialScreen extends StatefulWidget {
  const DialScreen({Key? key}) : super(key: key);

  @override
  State<DialScreen> createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    tasks.add(Task(
      title: '--', 
      description: '--', 
      time: const TimeOfDay(
        hour: 23, minute: 59)));
    tasks.sort((a, b) => a.time.compareTo(b.time));
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      tasks.sort((a, b) => a.time.compareTo(b.time));
    });
  }

  void _updateTask(int index, Task task) {
    setState(() {
      tasks[index] = task;
      tasks.sort((a, b) => a.time.compareTo(b.time));
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
    return Scaffold(
      backgroundColor: const Color(0xffC4E6D5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Text(
                    'Tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E3F05),
                      fontSize: 48.0,
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
                      color: Color(0xFF1E3F05),
                      size: 36, // Increased icon size
                    ),
                  ),
                ]
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  if (index >= tasks.length) {
                    return const SizedBox.shrink();
                  }

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

                  return Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 18.0),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      if (divider != null) divider,
                      if (index == tasks.length - 1)
                        const SizedBox.shrink()
                      else
                        ListTile(
                        title: Text(tasks[index].title),
                        subtitle: Text(
                          '${tasks[index].description} - ${tasks[index].time.format(context)}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'update',
                            child: Text('Update'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
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
                    ),
                  );
                },
              ),
            ),]
          ),
        ),
      );
    }

  Future<void> _showAddDialog(BuildContext context) async {
    String title = '';
    String description = '';
    TimeOfDay? time;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title: const Text(
              'add task',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3F05),
                fontSize: 28.0,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'title'),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'description'),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  },
                  child: const Text('Select Time'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (title.isNotEmpty &&
                      description.isNotEmpty &&
                      time != null) {
                    _addTask(
                      Task(title: title, description: description, time: time!),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
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

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
                controller: TextEditingController(text: title),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
                controller: TextEditingController(text: description),
              ),
              ElevatedButton(
                onPressed: () async {
                  time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: const Text('Select Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty &&
                    description.isNotEmpty &&
                    time != null) {
                  _updateTask(
                    index,
                    Task(title: title, description: description, time: time!),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
