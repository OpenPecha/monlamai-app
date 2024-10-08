import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/favorite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'favorites_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT PRIMARY KEY,
            sourceText TEXT,
            targetText TEXT,
            sourceLang TEXT,
            targetLang TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFavorite(Favorite favorite) async {
    final Database db = await database;
    var result = await db.insert(
      'favorites',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("Favorite inserted: $result");
  }

  Future<List<Favorite>> getFavorites() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('favorites', orderBy: 'createdAt DESC');
    // Convert the List<Map<String, dynamic> into a List<Favorite>
    return List.generate(maps.length, (i) {
      return Favorite.fromMap(maps[i]);
    });
  }

  // check if the favorite exists in the database
  Future<bool> isFavorite(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  Future<void> deleteFavorite(String id) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
