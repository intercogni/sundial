import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/event.dart';
import 'package:sundial/objectbox.g.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Box<Event> eventBox;
  late List<Event> events;

  @override
  void initState() {
    super.initState();
    eventBox = Provider.of<Store>(context, listen: false).box<Event>();
    _loadEvents();
  }

  void _loadEvents() {
    events = eventBox.getAll();
    for (var event in events) {
      event.restoreTimes();
    }
    setState(() {});
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
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
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

                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: startTime ?? TimeOfDay.now(),
                      );
                      if (pickedDate != null && pickedTime != null) {
                        startDate = pickedDate;
                        startTime = pickedTime;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        (startDate != null && startTime != null)
                            ? 'Start: ${_formatDateTime(startDate!, startTime!)}'
                            : 'Start Date & Time',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: endTime ?? TimeOfDay.now(),
                      );
                      if (pickedDate != null && pickedTime != null) {
                        endDate = pickedDate;
                        endTime = pickedTime;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        (endDate != null && endTime != null)
                            ? 'End: ${_formatDateTime(endDate!, endTime!)}'
                            : 'End Date & Time',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
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

                          final newEvent = Event.create(
                            title: titleController.text,
                            description: notesController.text,
                            startTime: startTime!,
                            endTime: endTime!,
                            startDate: startDate!,
                            endDate: endDate!,
                          );
                          if (isEdit) {
                            newEvent.id = event!.id;
                          }
                          eventBox.put(newEvent);
                          Navigator.pop(context);
                          _loadEvents();
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
  }

  void _deleteEvent(int index) {
    final event = events[index];
    eventBox.remove(event.id);
    _loadEvents();
  }

  void _showUpdateDialog(BuildContext context, int index) {
    final event = events[index];
    _showEventDialog(event: event);
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final minutes = duration.inMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
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
      body: ListView.builder(
        itemCount: events.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final event = events[index];
          final startTime = event.startTime!;
          final endTime = event.endTime!;
          final startDate = event.startDate!;
          final endDate = event.endDate!;

          final startDateTime = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            startTime.hour,
            startTime.minute,
          );
          final endDateTime = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            endTime.hour,
            endTime.minute,
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
                    '${_formatDateTime(startDate, startTime)}  - ${_formatDateTime(endDate, endTime)}',
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
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                onSelected: (value) {
                  if (value == 'update') {
                    _showUpdateDialog(context, index);
                  } else if (value == 'delete') {
                    _deleteEvent(index);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
