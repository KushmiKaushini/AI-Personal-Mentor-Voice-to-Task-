import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        subject TEXT NOT NULL,
        task_name TEXT NOT NULL,
        description TEXT,
        deadline TEXT,
        status TEXT DEFAULT 'pending',
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        name TEXT PRIMARY KEY
      )
    ''');
  }

  // Task CRUD
  Future<void> insertTask(Task task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'id DESC');
    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> updateTaskStatus(int id, String status) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllTasks() async {
    final db = await instance.database;
    await db.delete('tasks');
  }

  // Subjects
  Future<void> saveSubjects(List<String> subjects) async {
    final db = await instance.database;
    await db.delete('subjects');
    for (var subject in subjects) {
      await db.insert('subjects', {'name': subject});
    }
  }

  Future<List<String>> getSubjects() async {
    final db = await instance.database;
    final result = await db.query('subjects');
    return result.map((row) => row['name'] as String).toList();
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}
