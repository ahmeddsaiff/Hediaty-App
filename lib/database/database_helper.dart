// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'dart:async';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;
//
//   factory DatabaseHelper() {
//     return _instance;
//   }
//
//   DatabaseHelper._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'hedieaty.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE Users (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         fullName TEXT,
//         email TEXT,
//         phone TEXT,
//         uid TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE Events (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT,
//         category TEXT,
//         status TEXT,
//         location TEXT,
//         description TEXT,
//         userId TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE Gifts (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT,
//         price REAL,
//         details TEXT,
//         pledgedBy TEXT,
//         event_id TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE Friends (
//         user_id INTEGER,
//         friend_id INTEGER,
//         PRIMARY KEY (user_id, friend_id),
//         FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
//         FOREIGN KEY (friend_id) REFERENCES Users(id) ON DELETE CASCADE
//       )
//     ''');
//   }
// }