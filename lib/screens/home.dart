import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

import 'package:sundial/functions/solar_api.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/solar_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<EventOnSunrise> _sunriseEventList = [];
  final List<EventOnSunset> _sunsetEventList = [];

  @override
  void initState() {
    super.initState();
    _solarEvents();
  }

  Future<void> _solarEvents() async {
    log("Awaiting solar event data");
    final result = await SolarApi.fetchSolar(-7.2575, 112.7521);
    log("Notice from solar event data");
    if (result != null) {
      final parsed = result['parsed'] as Map<String, DateTime>;
      setState(() {
        final sunrise = DateFormat.Hm().format(parsed['sunrise']!);
        final sunset = DateFormat.Hm().format(parsed['sunset']!);
        final solarNoon = DateFormat.Hm().format(parsed['solar_noon']!);
        final civilBegin = DateFormat.Hm().format(
          parsed['civil_twilight_begin']!,
        );
        final civilEnd = DateFormat.Hm().format(parsed['civil_twilight_end']!);
        final nauticalBegin = DateFormat.Hm().format(
          parsed['nautical_twilight_begin']!,
        );
        final nauticalEnd = DateFormat.Hm().format(
          parsed['nautical_twilight_end']!,
        );
        final astroBegin = DateFormat.Hm().format(
          parsed['astronomical_twilight_begin']!,
        );
        final astroEnd = DateFormat.Hm().format(
          parsed['astronomical_twilight_end']!,
        );
      });
      log("Successfully fetched solar event data");
    } else {
      log("Failed to fetch solar event data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final solarData = Provider.of<SolarData>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/gradient_background.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(999),
                          topRight: Radius.circular(999),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
    final solarData = Provider.of<SolarData>(context);

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
                  ? '${widget.minutes.abs()} minutes before sunrise.)'
                  : '${widget.minutes} minutes after sunrise!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text("Sunrise: ${solarData.sunrise?.format(context)}"),
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
