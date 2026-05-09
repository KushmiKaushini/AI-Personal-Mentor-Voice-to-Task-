import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/task.dart';

class ApiService {
  // Configurable API base URL - use environment variable in production
  // Default is localhost (works for Android emulator, iOS sim, and desktop)
  static String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static final Duration _timeout = Duration(seconds: 30);

  Future<List<String>> getSubjects() async {
    final response = await http
        .get(Uri.parse('$baseUrl/subjects/'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((s) => s.toString()).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<List<Task>> getTasks() async {
    final response = await http
        .get(Uri.parse('$baseUrl/tasks/'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    ).timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTaskStatus(int id, String status) async {
    final response = await http
        .patch(Uri.parse('$baseUrl/tasks/$id?status=$status'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task status');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/tasks/$id'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<List<Task>> getTasksBySubject(String subject) async {
    final response = await http
        .get(Uri.parse('$baseUrl/tasks/$subject'))
        .timeout(_timeout);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks for $subject');
    }
  }

  Future<void> uploadVoiceInput(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/process-voice/'));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send().timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to process voice input');
    }
  }
}
