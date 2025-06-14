import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'tasks'; 

  
  Future<void> addTask(Task task) async {
    try {
      await _db.collection(_collectionName).add(task.toFirestore());
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  
  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw ArgumentError('Task ID cannot be null for updating a task.');
    }
    try {
      await _db.collection(_collectionName).doc(task.id).update(task.toFirestore());
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection(_collectionName).doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  
  Stream<List<Task>> getTasksStream() {
    return _db.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  
  Future<Task?> getTaskById(String taskId) async {
    try {
      final doc = await _db.collection(_collectionName).doc(taskId).get();
      if (doc.exists) {
        return Task.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting task by ID: $e');
      rethrow;
    }
  }
}
