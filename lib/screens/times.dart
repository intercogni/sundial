import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/event.dart';
import 'package:sundial/services/event_service.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final EventService _eventService = EventService();
  late Stream<List<Event>> _eventStream;

  @override
  void initState() {
    super.initState();
    _eventStream = _eventService.getEventsStream();
  }

  void _showEventDialog({Event? event}) {
    final isEdit = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final notesController = TextEditingController(text: event?.note ?? '');

    DateTime? startDate = event?.startDate ?? DateTime.now();
    DateTime? endDate = event?.endDate ?? DateTime.now();
    TimeOfDay? startTime = event?.startTime;
    TimeOfDay? endTime = event?.endTime;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              content: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEdit ? 'Edit Event' : 'Add Event',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelText: 'Title',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: notesController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          labelText: 'Notes (optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildDateTimePicker(
                        label: 'Start Date & Time',
                        date: startDate,
                        time: startTime,
                        onDateTimeSelected: (d, t) {
                          setStateDialog(() {
                            startDate = d;
                            startTime = t;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildDateTimePicker(
                        label: 'End Date & Time',
                        date: endDate,
                        time: endTime,
                        onDateTimeSelected: (d, t) {
                          setStateDialog(() {
                            endDate = d;
                            endTime = t;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                              elevation: 4,
                            ),
                            onPressed: () {
                              if (titleController.text.isEmpty ||
                                  startDate == null ||
                                  endDate == null ||
                                  startTime == null ||
                                  endTime == null)
                                return;

                              final startDateTime = DateTime(
                                startDate!.year,
                                startDate!.month,
                                startDate!.day,
                                startTime!.hour,
                                startTime!.minute,
                              );
                              final endDateTime = DateTime(
                                endDate!.year,
                                endDate!.month,
                                endDate!.day,
                                endTime!.hour,
                                endTime!.minute,
                              );

                              if (endDateTime.isBefore(startDateTime)) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.red.withOpacity(
                                        0.9,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      content: const Text(
                                        'End time must be after start time.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }

                              final newEvent = Event.create(
                                title: titleController.text,
                                description: notesController.text,
                                startTime: startTime!,
                                endTime: endTime!,
                                startDate: startDate!,
                                endDate: endDate!,
                              );
                              if (isEdit) newEvent.id = event!.id;
                              _saveEvent(newEvent, isEdit: isEdit);
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required Function(DateTime, TimeOfDay) onDateTimeSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: time ?? TimeOfDay.now(),
          );

          if (pickedTime != null) {
            onDateTimeSelected(pickedDate, pickedTime);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          (date != null && time != null)
              ? '$label: ${_formatDateTime(date, time)}'
              : label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _saveEvent(Event event, {bool isEdit = false}) {
    if (isEdit) {
      _eventService.updateEvent(event);
    } else {
      _eventService.addEvent(event);
    }
  }

  void _deleteEvent(String id) {
    _eventService.deleteEvent(id);
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final minutes = duration.inMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return hours > 0
        ? '${hours}h ${remainingMinutes}m'
        : '${remainingMinutes}m';
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${_monthName(date.month)} ${date.day}, ${date.year} at $hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1E3C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Events',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEventDialog(),
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventStream,
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No events yet',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final event = events[index];
              event.restoreTimes();

              final startDateTime = DateTime(
                event.startDate!.year,
                event.startDate!.month,
                event.startDate!.day,
                event.startTime!.hour,
                event.startTime!.minute,
              );
              final endDateTime = DateTime(
                event.endDate!.year,
                event.endDate!.month,
                event.endDate!.day,
                event.endTime!.hour,
                event.endTime!.minute,
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white10,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatDateTime(event.startDate!, event.startTime!)} - ${_formatDateTime(event.endDate!, event.endTime!)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(startDateTime, endDateTime),
                        style: const TextStyle(color: Colors.white54),
                      ),
                      if (event.note != null && event.note!.isNotEmpty)
                        Text(
                          event.note!,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white60,
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'update',
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'update') {
                        _showEventDialog(event: event);
                      } else if (value == 'delete') {
                        _deleteEvent(event.id!);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
