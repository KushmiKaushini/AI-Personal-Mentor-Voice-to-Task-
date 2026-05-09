import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<String> _subjects = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService.instance;

  List<Task> get tasks => _tasks;
  List<String> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await fetchSubjects();
    await fetchTasks();
  }

  Future<void> fetchSubjects() async {
    try {
      // Try fetching from API
      _subjects = await _apiService.getSubjects();
      await _dbService.saveSubjects(_subjects);
    } catch (e) {
      // Fallback to local DB
      _subjects = await _dbService.getSubjects();
      debugPrint('Error fetching subjects from API, using local: $e');
    }
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Load local first for instant UI
      _tasks = await _dbService.getAllTasks();
      notifyListeners();

      // Sync with API
      final remoteTasks = await _apiService.getTasks();
      
      // Update local DB with remote data
      await _dbService.clearAllTasks();
      for (var task in remoteTasks) {
        await _dbService.insertTask(task);
      }
      
      _tasks = remoteTasks;
    } catch (e) {
      debugPrint('Error syncing tasks: $e. Using local data.');
      _tasks = await _dbService.getAllTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = await _apiService.createTask(task);
      await _dbService.insertTask(newTask);
      _tasks.insert(0, newTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTaskStatus(int id, String status) async {
    try {
      await _apiService.updateTaskStatus(id, status);
      await _dbService.updateTaskStatus(id, status);
      
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final originalTask = _tasks[index];
        _tasks[index] = Task(
          id: originalTask.id,
          subject: originalTask.subject,
          taskName: originalTask.taskName,
          description: originalTask.description,
          deadline: originalTask.deadline,
          status: status,
          createdAt: originalTask.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiService.deleteTask(id);
      await _dbService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  List<Task> getTasksBySubject(String subject) {
    return _tasks.where((task) => task.subject == subject).toList();
  }

  Future<void> processVoiceInput(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.uploadVoiceInput(filePath);
      await fetchTasks();
    } catch (e) {
      debugPrint('Error processing voice: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
