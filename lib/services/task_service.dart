import 'package:sundial/models/task.dart';
import 'package:sundial/objectbox.dart';
import 'package:sundial/objectbox.g.dart'; 
import 'package:sundial/main.dart'; 

class TaskService {
  late final Box<Task> _taskBox;

  TaskService() {
    _taskBox = objectbox.store.box<Task>();
  }

  
  int addTask(Task task) {
    return _taskBox.put(task);
  }

  
  List<Task> getAllTasks() {
    return _taskBox.getAll();
  }

  
  void updateTask(Task task) {
    _taskBox.put(task);
  }

  
  bool deleteTask(int id) {
    return _taskBox.remove(id);
  }

  
  Task? getTaskById(int id) {
    return _taskBox.get(id);
  }
}
