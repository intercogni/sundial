import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math'; 
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sundial/screens/location_selection_screen.dart';
import 'package:sundial/services/daily_solar_data_service.dart';
import 'package:sundial/models/daily_solar_data.dart';
import 'package:sundial/functions/solar_api.dart';
import 'package:sundial/models/task.dart';
import 'package:sundial/services/task_firestore_service.dart';
import 'package:sundial/models/solar_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DailySolarDataService _dailySolarDataService = DailySolarDataService();
  final TaskFirestoreService _taskService = TaskFirestoreService();
  List<Appointment> _appointments = <Appointment>[];

  @override
  void initState() {
    super.initState();
    _fetchAndSetAppointments(DateTime.now(), DateTime.now().add(const Duration(days: 7))); 
  }

  TimeOfDay? _getTaskTime(Task task, DailySolarData? solarData) {
    if (!task.isRelative) {
      return TimeOfDay.fromDateTime(task.dueDate);
    }

    if (task.solarEvent == null || task.offsetMinutes == null || solarData == null) {
      return null;
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
        return null;
    }

    if (solarEventTime == null) {
      return null;
    }

    final totalMinutes = solarEventTime.hour * 60 + solarEventTime.minute + task.offsetMinutes!;
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;

    return TimeOfDay(hour: hour % 24, minute: minute);
  }

  void _fetchAndSetAppointments(DateTime startDate, DateTime endDate) {
    final List<Appointment> combinedAppointments = [];

    
    _dailySolarDataService.getDailySolarDataStream(startDate, endDate).listen((dailySolarDataList) {
      final Map<DateTime, DailySolarData> dailyDataMap = {};
      for (var dailyData in dailySolarDataList) {
        final dateKey = DateTime(dailyData.date.year, dailyData.date.month, dailyData.date.day);
        dailyDataMap[dateKey] = dailyData;
      }

      final List<Appointment> solarAppointments = [];
      for (var dailyData in dailyDataMap.values) {
        if (dailyData.astronomicalTwilightBegin != null) {
          final astronomicalTwilightBeginDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.astronomicalTwilightBegin!.hour,
            dailyData.astronomicalTwilightBegin!.minute,
          );
          solarAppointments.add(Appointment(
            startTime: astronomicalTwilightBeginDateTime.subtract(const Duration(minutes: 19)),
            endTime: astronomicalTwilightBeginDateTime.add(const Duration(minutes: 19)),
            subject: 'fl—',
            color: Colors.transparent,
          ));
        }
        if (dailyData.nauticalTwilightBegin != null) {
          final nauticalTwilightBeginDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.nauticalTwilightBegin!.hour,
            dailyData.nauticalTwilightBegin!.minute,
          );
          solarAppointments.add(Appointment(
            startTime: nauticalTwilightBeginDateTime.subtract(const Duration(minutes: 19)),
            endTime: nauticalTwilightBeginDateTime.add(const Duration(minutes: 19)),
            subject: 'ds—',
            color: Colors.transparent,
          ));
        }
        if (dailyData.sunrise != null) {
          final sunriseDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.sunrise!.hour,
            dailyData.sunrise!.minute,
          );
          solarAppointments.add(Appointment(
            startTime: sunriseDateTime.subtract(const Duration(minutes: 19)),
            endTime: sunriseDateTime.add(const Duration(minutes: 19)),
            subject: 'sr—',
            color: Colors.transparent,
          ));
        }
        if (dailyData.solarNoon != null) {
          final solarNoonDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.solarNoon!.hour,
            dailyData.solarNoon!.minute,
          );
          solarAppointments.add(Appointment(
            startTime: solarNoonDateTime.subtract(const Duration(minutes: 19)),
            endTime: solarNoonDateTime.add(const Duration(minutes: 19)),
            subject: 'sn—',
            color: Colors.transparent,
          ));
        }
        if (dailyData.sunset != null) {
          final sunsetDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.sunset!.hour,
            dailyData.sunset!.minute,
          );
          solarAppointments.add(Appointment(
            startTime: sunsetDateTime.subtract(const Duration(minutes: 19)),
            endTime: sunsetDateTime.add(const Duration(minutes: 19)),
            subject: 'ss—',
            color: Colors.transparent,
          ));
        }
        if (dailyData.nauticalTwilightEnd != null) {
          final nauticalTwilightEndDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.nauticalTwilightEnd!.hour,
            dailyData.nauticalTwilightEnd!.minute,
          );
          solarAppointments.add(Appointment(
            startTime: nauticalTwilightEndDateTime.subtract(const Duration(minutes: 19)),
            endTime: nauticalTwilightEndDateTime.add(const Duration(minutes: 19)),
            subject: 'll—',
            color: Colors.transparent,
          ));
        }
        if (dailyData.astronomicalTwilightEnd != null) {
          final astronomicalTwilightEndDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.astronomicalTwilightEnd!.hour,
            dailyData.astronomicalTwilightEnd!.minute,
          );
          solarAppointments.add(Appointment(
            startTime: astronomicalTwilightEndDateTime.subtract(const Duration(minutes: 19)),
            endTime: astronomicalTwilightEndDateTime.add(const Duration(minutes: 19)),
            subject: 'nh—',
            color: Colors.transparent,
          ));
        }
      }
      combinedAppointments.addAll(solarAppointments);

      _taskService.getTasksStream().listen((tasks) {
        final List<Appointment> taskAppointments = [];
        for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
          final currentDate = startDate.add(Duration(days: i));
          final DailySolarData? solarDataForCurrentDate = dailyDataMap[DateTime(currentDate.year, currentDate.month, currentDate.day)];

          for (var task in tasks) {
            bool shouldAdd = false;

            if (task.repeatOptions == null || task.repeatOptions!.type == RepeatType.none) {
              
              if (task.dueDate.year == currentDate.year &&
                  task.dueDate.month == currentDate.month &&
                  task.dueDate.day == currentDate.day) {
                shouldAdd = true;
              }
            } else if (task.repeatOptions!.type == RepeatType.daily) {
              
              shouldAdd = true;
            } else if (task.repeatOptions!.type == RepeatType.weekly) {
              
              
              if (task.repeatOptions!.selectedDays.contains(currentDate.weekday)) {
                shouldAdd = true;
              }
            }

            if (shouldAdd) {
              final TimeOfDay? taskTime = _getTaskTime(task, solarDataForCurrentDate);

              if (taskTime != null) {
                final taskDateTime = DateTime(
                  currentDate.year,
                  currentDate.month,
                  currentDate.day,
                  taskTime.hour,
                  taskTime.minute,
                );

                taskAppointments.add(Appointment(
                  startTime: taskDateTime.subtract(const Duration(minutes: 20)),
                  endTime: taskDateTime.add(const Duration(minutes: 20)), 
                  subject: task.title,
                  color: _generateColorForTime(task.title), 
                  isAllDay: false,
                ));
              }
            }
          }
        }
        combinedAppointments.addAll(taskAppointments);
        setState(() {
          _appointments = combinedAppointments;
        });
      });
    });
  }

  Color _generateColorForTime(String taskName) {
    
    final int seed = taskName.hashCode;
    final Random random = Random(seed);
    return Color.fromARGB(
      255, 
      random.nextInt(200) + 10, 
      random.nextInt(200) + 10, 
      random.nextInt(200) + 10, 
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            const SizedBox(height: 50),
            Expanded(
              child: SfCalendar(
                view: CalendarView.week,
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                  agendaStyle: AgendaStyle(
                    backgroundColor: Colors.transparent,
                    appointmentTextStyle: TextStyle(color: Colors.black),
                    dateTextStyle: TextStyle(color: Colors.black),
                    dayTextStyle: TextStyle(color: Colors.black),
                  ),
                ),
                headerStyle: const CalendarHeaderStyle(
                  backgroundColor: Colors.transparent,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                viewHeaderStyle: const ViewHeaderStyle(
                  dayTextStyle: TextStyle(color: Colors.white),
                ),
                todayTextStyle: const TextStyle(color: Colors.white),
                cellBorderColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                selectionDecoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  shape: BoxShape.rectangle,
                ),
                initialSelectedDate: DateTime.now(),
                initialDisplayDate: DateTime.now(),
                todayHighlightColor: Colors.green.shade300,
                headerHeight: 50,
                dataSource: _getCalendarDataSource(),
                onViewChanged: (ViewChangedDetails details) {
                  if (details.visibleDates.isNotEmpty) {
                    final startDate = details.visibleDates.first;
                    final endDate = details.visibleDates.last;
                    _fetchAndSetAppointments(startDate, endDate);
                  }
                },
              ),
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0, right: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(90.0),
            topRight: Radius.circular(90.0),
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(90.0),
                  topRight: Radius.circular(90.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationSelectionScreen(),
                    ),
                  );
                  if (result != null) {
                    final selectedLocation = result['location'];
                    final selectedDateRange = result['dateRange'];
                    final selectedLocationName = result['locationName'];

                    if (selectedLocation != null && selectedDateRange != null) {
                      final startDate = selectedDateRange.start;
                      final endDate = selectedDateRange.end;

                      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
                        final currentDate = startDate.add(Duration(days: i));
                        try {
                          final solarData = await SolarApi.fetchSolar(
                            selectedLocation.latitude,
                            selectedLocation.longitude,
                          );

                          if (solarData != null && solarData['parsed'] != null) {
                            final parsedSolarEvents = solarData['parsed'] as Map<String, DateTime>;

                            final dailyData = DailySolarData(
                              date: currentDate,
                              latitude: selectedLocation.latitude,
                              longitude: selectedLocation.longitude,
                              locationName: selectedLocationName,
                              sunrise: parsedSolarEvents['sunrise'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['sunrise']!) : null,
                              sunset: parsedSolarEvents['sunset'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['sunset']!) : null,
                              solarNoon: parsedSolarEvents['solar_noon'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['solar_noon']!) : null,
                              astronomicalTwilightBegin: parsedSolarEvents['astronomical_twilight_begin'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['astronomical_twilight_begin']!) : null,
                              astronomicalTwilightEnd: parsedSolarEvents['astronomical_twilight_end'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['astronomical_twilight_end']!) : null,
                              nauticalTwilightBegin: parsedSolarEvents['nautical_twilight_begin'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['nautical_twilight_begin']!) : null,
                              nauticalTwilightEnd: parsedSolarEvents['nautical_twilight_end'] != null ? TimeOfDay.fromDateTime(parsedSolarEvents['nautical_twilight_end']!) : null,
                            );

                            await _dailySolarDataService.addDailySolarData(dailyData);
                          } else {
                            print('Failed to fetch solar data for ${currentDate.toLocal()}');
                          }
                        } catch (e) {
                          print('Error saving solar data for ${currentDate.toLocal()}: $e');
                        }
                      }
                    }
                  }
                },
                child: const Icon(Icons.location_on),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _AppointmentDataSource _getCalendarDataSource() {
    return _AppointmentDataSource(_appointments);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
