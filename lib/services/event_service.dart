import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'events';

  Future<void> addEvent(Event event) async {
    await _db.collection(_collection).add(event.toFirestore());
  }

  Future<void> updateEvent(Event event) async {
    if (event.id == null) throw Exception('Event ID null');
    await _db.collection(_collection).doc(event.id).update(event.toFirestore());
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  Future<Event?> getEventById(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Event.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<Event>> getEventsStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
}
