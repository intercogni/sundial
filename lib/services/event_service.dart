import 'package:sundial/models/event.dart';
import 'package:sundial/objectbox.g.dart';
import 'package:sundial/main.dart';

class EventService {
  late final Box<Event> _eventBox;
  EventService() {
    _eventBox = objectbox.store.box<Event>();
  }
  int addEvent(Event event) {
    return _eventBox.put(event);
  }

  List<Event> getAllEvents() {
    final events = _eventBox.getAll();
    for (final e in events) {
      e.restoreTimes();
    }
    return events;
  }

  void updateEvent(Event event) {
    _eventBox.put(event);
  }

  bool deleteEvent(int id) {
    return _eventBox.remove(id);
  }

  Event? getEventById(int id) {
    final e = _eventBox.get(id);
    e?.restoreTimes();
    return e;
  }
}
