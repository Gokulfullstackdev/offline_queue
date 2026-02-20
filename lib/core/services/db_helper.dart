import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "offline_app.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE notes(
          id TEXT PRIMARY KEY,
          title TEXT,
          content TEXT,
          updatedAt INTEGER,
          isSynced INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE sync_queue(
          id TEXT PRIMARY KEY,
          actionType TEXT,
          payload TEXT,
          idempotencyKey TEXT,
          retryCount INTEGER,
          status TEXT,
          createdAt INTEGER
        )
        ''');
      },
    );
  }
}
