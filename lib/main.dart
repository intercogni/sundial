import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
    channelShowBadge: true,
  ),
],
);
AwesomeNotifications().requestPermissionToSendNotifications();
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sundial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 195, 28, 28),
        ),
      ),
      home: const MyHomePage(title: 'Sundial'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<EventOnSunrise> _sunriseEventList = [];
  final List<EventOnSunset> _sunsetEventList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(163, 255, 234, 212),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.inversePrimary,
                blurRadius: 2.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 32),

            Expanded(
              child: ListView.builder(
                itemCount: _sunriseEventList.length,
                itemBuilder: (context, index) {
                  final event = _sunriseEventList[index];
                  return Row(
                    children: [
                      Expanded(
                        child: EventOnSunrise(
                          title: event.title,
                          minutes: event.minutes,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final TextEditingController titleController =
                                  TextEditingController(text: event.title);
                              final TextEditingController minutesController =
                                  TextEditingController(
                                    text: event.minutes.toString(),
                                  );

                              return AlertDialog(
                                title: const Text('Edit Sunset Event'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                      ),
                                    ),
                                    TextField(
                                      controller: minutesController,
                                      decoration: const InputDecoration(
                                        labelText: 'Minutes',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final String updatedTitle =
                                          titleController.text;
                                      final int? updatedMinutes = int.tryParse(
                                        minutesController.text,
                                      );

                                      if (updatedTitle.isNotEmpty &&
                                          updatedMinutes != null) {
                                        setState(() {
                                          _sunriseEventList[index] =
                                              EventOnSunrise(
                                                title: updatedTitle,
                                                minutes: updatedMinutes,
                                              );
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _sunriseEventList.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  );
                },
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _sunsetEventList.length,
                itemBuilder: (context, index) {
                  final event = _sunsetEventList[index];
                  return Row(
                    children: [
                      Expanded(
                        child: EventOnSunset(
                          title: event.title,
                          minutes: event.minutes,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final TextEditingController titleController =
                                  TextEditingController(text: event.title);
                              final TextEditingController minutesController =
                                  TextEditingController(
                                    text: event.minutes.toString(),
                                  );

                              return AlertDialog(
                                title: const Text('Edit Sunset Event'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                      ),
                                    ),
                                    TextField(
                                      controller: minutesController,
                                      decoration: const InputDecoration(
                                        labelText: 'Minutes',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final String updatedTitle =
                                          titleController.text;
                                      final int? updatedMinutes = int.tryParse(
                                        minutesController.text,
                                      );

                                      if (updatedTitle.isNotEmpty &&
                                          updatedMinutes != null) {
                                        setState(() {
                                          _sunsetEventList[index] =
                                              EventOnSunset(
                                                title: updatedTitle,
                                                minutes: updatedMinutes,
                                              );
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _sunsetEventList.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final TextEditingController titleController =
                            TextEditingController();
                        final TextEditingController minutesController =
                            TextEditingController();

                        return AlertDialog(
                          title: const Text('Add Sunrise Event'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                ),
                              ),
                              TextField(
                                controller: minutesController,
                                decoration: const InputDecoration(
                                  labelText: 'Minutes',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final String title = titleController.text;
                                final int? minutes = int.tryParse(
                                  minutesController.text,
                                );

                                if (title.isNotEmpty && minutes != null) {
                                    setState(() {
                                      _sunriseEventList.add(
                                        EventOnSunrise(
                                          title: title,
                                          minutes: minutes,
                                        ),
                                      );
                                    });
                                    AwesomeNotifications().createNotification(
                                      content: NotificationContent(
                                        id: 11,
                                        channelKey: 'basic_channel',
                                        title: 'Sunrise Event Added!',
                                        body: 'A new sunrise event "$title" has been added.',
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Add Sunrise Event'),
                  ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final TextEditingController titleController =
                            TextEditingController();
                        final TextEditingController minutesController =
                            TextEditingController();

                        return AlertDialog(
                          title: const Text('Add Sunset Event'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                ),
                              ),
                              TextField(
                                controller: minutesController,
                                decoration: const InputDecoration(
                                  labelText: 'Minutes',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final String title = titleController.text;
                                final int? minutes = int.tryParse(
                                  minutesController.text,
                                );

                                if (title.isNotEmpty && minutes != null) {
                                  setState(() {
                                    _sunsetEventList.add(
                                      EventOnSunset(
                                        title: title,
                                        minutes: minutes,
                                      ),
                                    );
                                  });
                                  AwesomeNotifications().createNotification(
                                    content: NotificationContent(
                                      id: 12,
                                      channelKey: 'basic_channel',
                                      title: 'Sunset Event Added!',
                                      body: 'A new sunset event "$title" has been added.',
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Add Sunset Event'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: 10,
                    channelKey: 'basic_channel',
                    title: 'Hello from Sundial!',
                    body: 'This is a test notification.',
                  ),
                );
              },
              child: const Text('Show Notification'),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class EventOnSunrise extends StatefulWidget {
  final String title;
  final int minutes;

  const EventOnSunrise({super.key, required this.minutes, required this.title});

  @override
  State<EventOnSunrise> createState() => _EventOnSunriseState();
}

class _EventOnSunriseState extends State<EventOnSunrise> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(173, 0, 136, 255),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 0),
            Text(
              widget.minutes == 0
                  ? 'on sunrise'
                  : widget.minutes < 0
                  ? '${widget.minutes.abs()} minutes before sunrise.'
                  : '${widget.minutes} minutes after sunrise.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class EventOnSunset extends StatefulWidget {
  final String title;
  final int minutes;

  const EventOnSunset({super.key, required this.minutes, required this.title});

  @override
  State<EventOnSunset> createState() => _EventOnSunsetState();
}

class _EventOnSunsetState extends State<EventOnSunset> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(173, 0, 136, 255),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 0),
            Text(
              widget.minutes == 0
                  ? 'on sunset'
                  : widget.minutes < 0
                  ? '${widget.minutes.abs()} minutes before sunset.'
                  : '${widget.minutes} minutes after sunset.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
