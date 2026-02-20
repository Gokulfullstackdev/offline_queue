// lib/features/data/repository/node_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 2, // Increment version to trigger onUpgrade
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            isSynced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Handle database upgrade
          // This will recreate the table with correct schema
          await db.execute('DROP TABLE IF EXISTS notes');
          await db.execute('''
            CREATE TABLE notes(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              isSynced INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
      },
    );
  }

  // Add note - FIXED with null safety
  Future<NoteModel> addNote(String title, String content) async {
    final db = await database;
    final id = await db.insert(
      'notes',
      {
        'title': title,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
        'isSynced': 0, // Make sure this is never null
      },
    );

    return NoteModel(
      id: id,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      isSynced: 0,
    );
  }

  // Get all notes - FIXED with null safety
  Future<List<NoteModel>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: "datetime(createdAt) DESC",
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];

      // Handle null values safely
      return NoteModel(
        id: map['id'] as int?, // Allow null for id
        title: map['title'] as String? ?? '', // Provide default if null
        content: map['content'] as String? ?? '',
        createdAt: _parseDateSafely(map['createdAt']),
        isSynced: map['isSynced'] as int? ?? 0, // Default to 0 if null
      );
    });
  }

  // Safe date parsing
  DateTime _parseDateSafely(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    try {
      return DateTime.parse(dateValue.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Update sync status
  Future<void> updateSyncStatus(int id, int isSynced) async {
    final db = await database;
    await db.update(
      'notes',
      {'isSynced': isSynced},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get pending sync notes
  Future<List<NoteModel>> getPendingSyncNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'isSynced = ?',
      whereArgs: [0],
      orderBy: "datetime(createdAt) ASC",
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return NoteModel(
        id: map['id'] as int?,
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        createdAt: _parseDateSafely(map['createdAt']),
        isSynced: map['isSynced'] as int? ?? 0,
      );
    });
  }

  // Search notes
  Future<List<NoteModel>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: "datetime(createdAt) DESC",
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return NoteModel(
        id: map['id'] as int?,
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        createdAt: _parseDateSafely(map['createdAt']),
        isSynced: map['isSynced'] as int? ?? 0,
      );
    });
  }

  // Clear all notes
  Future<void> clearAllNotes() async {
    final db = await database;
    await db.delete('notes');
  }

  // Fix existing data (run this once to clean up null values)
  Future<void> fixExistingData() async {
    final db = await database;

    // Update any rows with NULL values
    await db.rawUpdate('''
      UPDATE notes 
      SET isSynced = 0 
      WHERE isSynced IS NULL
    ''');

    await db.rawUpdate('''
      UPDATE notes 
      SET title = '' 
      WHERE title IS NULL
    ''');

    await db.rawUpdate('''
      UPDATE notes 
      SET content = '' 
      WHERE content IS NULL
    ''');

    await db.rawUpdate('''
      UPDATE notes 
      SET createdAt = ? 
      WHERE createdAt IS NULL
    ''', [DateTime.now().toIso8601String()]);
  }
}