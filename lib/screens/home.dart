import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sundial/screens/location_selection_screen.dart';
import 'package:sundial/services/daily_solar_data_service.dart';
import 'package:sundial/models/daily_solar_data.dart';
import 'package:sundial/functions/solar_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DailySolarDataService _dailySolarDataService = DailySolarDataService();
  List<Appointment> _appointments = <Appointment>[];

  @override
  void initState() {
    super.initState();
    _fetchAndSetAppointments(DateTime.now(), DateTime.now().add(const Duration(days: 7))); 
  }

  void _fetchAndSetAppointments(DateTime startDate, DateTime endDate) {
    _dailySolarDataService.getDailySolarDataStream(startDate, endDate).listen((dailySolarDataList) {
      final Map<DateTime, DailySolarData> dailyDataMap = {};
      for (var dailyData in dailySolarDataList) {
        
        final dateKey = DateTime(dailyData.date.year, dailyData.date.month, dailyData.date.day);
        dailyDataMap[dateKey] = dailyData; 
      }

      final List<Appointment> appointments = [];
      for (var dailyData in dailyDataMap.values) {
        if (dailyData.sunrise != null) {
          final sunriseDateTime = DateTime(
            dailyData.date.year,
            dailyData.date.month,
            dailyData.date.day,
            dailyData.sunrise!.hour,
            dailyData.sunrise!.minute,
          );
          appointments.add(Appointment(
            startTime: sunriseDateTime.subtract(const Duration(minutes: 20)),
            endTime: sunriseDateTime.add(const Duration(minutes: 20)), 
            subject: '—sr—',
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
          appointments.add(Appointment(
            startTime: sunsetDateTime.subtract(const Duration(minutes: 20)),
            endTime: sunsetDateTime.add(const Duration(minutes: 20)), 
            subject: '—ss—',
            color: Colors.transparent,
          ));
        }
      }
      setState(() {
        _appointments = appointments;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
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
          ),
        ],
      ),
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
        child: SfCalendar(
          view: CalendarView.week,
          monthViewSettings: const MonthViewSettings(
            showAgenda: true,
            agendaStyle: AgendaStyle(
              backgroundColor: Colors.white,
              appointmentTextStyle: TextStyle(color: Colors.black),
              dateTextStyle: TextStyle(color: Colors.black),
              dayTextStyle: TextStyle(color: Colors.black),
            ),
          ),
          headerStyle: const CalendarHeaderStyle(
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
