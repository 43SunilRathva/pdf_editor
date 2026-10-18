import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pdf_editor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable foreign keys in SQLite
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documents (
        doc_id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL UNIQUE,
        file_size_kb INTEGER,
        total_pages INTEGER,
        last_opened DATETIME DEFAULT CURRENT_TIMESTAMP,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        bookmark_id INTEGER PRIMARY KEY AUTOINCREMENT,
        doc_id INTEGER,
        page_number INTEGER NOT NULL,
        bookmark_title TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (doc_id) REFERENCES documents(doc_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE edit_history (
        history_id INTEGER PRIMARY KEY AUTOINCREMENT,
        doc_id INTEGER,
        action_type TEXT,
        action_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (doc_id) REFERENCES documents(doc_id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  Future<int> insertDocument(DocumentModel document) async {
    final db = await instance.database;
    return await db.insert(
      'documents',
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentFiles() async {
    final db = await instance.database;
    return await db.query('documents', orderBy: 'last_opened DESC');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
