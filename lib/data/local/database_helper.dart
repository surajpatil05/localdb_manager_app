import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Singleton class for handling database operations
class DatabaseHelper {
  // Creating a single instance of DatabaseHelper (Singleton pattern)
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Private constructor to prevent multiple instances
  static Database? _database;

  // Factory constructor to return the same instance every time
  factory DatabaseHelper() {
    return _instance;
  }

  // Named constructor for internal use
  DatabaseHelper._internal();

  // Getter for database instance, initializes if not already created
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Initializes and opens the database, creates tables if not exists
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'localdb_manager.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
        );
      },
    );
  }
}
