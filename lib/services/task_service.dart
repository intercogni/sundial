import 'package:sundial/models/task.dart';
import 'package:sundial/objectbox.dart';
import 'package:sundial/objectbox.g.dart'; // For Box
import 'package:sundial/main.dart'; // Import main.dart to access the global objectbox instance

class TaskService {
  late final Box<Task> _taskBox;

  TaskService() {
    _taskBox = objectbox.store.box<Task>();
  }

  /// Add a new task.
  int addTask(Task task) {
    return _taskBox.put(task);
  }

  /// Get all tasks.
  List<Task> getAllTasks() {
    return _taskBox.getAll();
  }

  /// Update an existing task.
  void updateTask(Task task) {
    _taskBox.put(task);
  }

  /// Delete a task by its ID.
  bool deleteTask(int id) {
    return _taskBox.remove(id);
  }

  /// Get a single task by its ID.
  Task? getTaskById(int id) {
    return _taskBox.get(id);
  }
}
