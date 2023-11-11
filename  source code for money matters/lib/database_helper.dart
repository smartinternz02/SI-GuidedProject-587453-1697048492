import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "expense_tracker.db";
  static final _databaseVersion = 1;

  static final table = 'users';
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnPassword = 'password';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnPassword TEXT NOT NULL
      )
    ''');

    // Add code here to create the 'expenses' table if needed
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
  }

  // Helper methods

  // Insert a user into the database
  Future<int> insert(Map<String, dynamic> row) async {
    final Database? db = await instance.database;
    return await db?.insert(table, row) ?? 0;
  }

  // Query a specific user by username and password
  Future<List<Map<String, dynamic>>> queryUser(String name,
      String password) async {
    Database? db = await instance.database;
    return await db?.query(table,
        where: '$columnName = ? AND $columnPassword = ?',
        whereArgs: [name, password]) ?? [];
  }
}
