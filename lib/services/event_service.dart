import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'package:flutter/foundation.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'events';

  Future<void> addEvent(Event event) async {
    try {
      await _db.collection(_collection).add(event.toFirestore());
    } catch (e) {
      debugPrint('Error adding event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    if (event.id == null) {
      throw ArgumentError('Event id null');
    }
    try {
      await _db
          .collection(_collection)
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      debugPrint('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting event: $e');
      rethrow;
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final doc = await _db.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Event.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting event by id: $e');
      rethrow;
    }
  }

  Stream<List<Event>> getEventsStream() {
    return FirebaseFirestore.instance.collection('events').snapshots().map((
      snapshot,
    ) {
      debugPrint('Snapshot received with ${snapshot.docs.length} documents');
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }
}
