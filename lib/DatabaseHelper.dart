import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  static final Databasehelper _instance = Databasehelper._internal();
  static Database? _database;

  factory Databasehelper() => _instance;
  Databasehelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'if.db'),
      version: 2,
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''CREATE TABLE IF NOT EXISTS disciplina(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            codigo TEXT NOT NULL UNIQUE
          )''');
          await db.execute('''CREATE TABLE IF NOT EXISTS cursando(
            estudante_id INTEGER NOT NULL,
            disciplina_id INTEGER NOT NULL,
            PRIMARY KEY (estudante_id, disciplina_id),
            FOREIGN KEY (estudante_id) REFERENCES estudante(id) ON DELETE CASCADE,
            FOREIGN KEY (disciplina_id) REFERENCES disciplina(id) ON DELETE CASCADE
          )''');
        }
      },
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''CREATE TABLE estudante(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      matricula TEXT NOT NULL UNIQUE
    )''');
    await db.execute('''CREATE TABLE disciplina(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      codigo TEXT NOT NULL UNIQUE
    )''');
    await db.execute('''CREATE TABLE cursando(
      estudante_id INTEGER NOT NULL,
      disciplina_id INTEGER NOT NULL,
      PRIMARY KEY (estudante_id, disciplina_id),
      FOREIGN KEY (estudante_id) REFERENCES estudante(id) ON DELETE CASCADE,
      FOREIGN KEY (disciplina_id) REFERENCES disciplina(id) ON DELETE CASCADE
    )''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
