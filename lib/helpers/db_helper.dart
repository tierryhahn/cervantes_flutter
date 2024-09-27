import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cadastro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cadastro (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            texto TEXT NOT NULL,
            numero INTEGER NOT NULL UNIQUE CHECK(numero > 0)
          );
        ''');

        await db.execute('''
          CREATE TABLE log_operacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operacao TEXT NOT NULL,
            data_hora TEXT NOT NULL
          );
        ''');
      },
    );
  }

  Future<int> insertCadastro(String texto, int numero) async {
    final db = await database;
    final result = await db.insert('cadastro', {
      'texto': texto,
      'numero': numero,
    });

    await _logOperacao('Insert');
    return result;
  }

  Future<int> updateCadastro(int id, String texto, int numero) async {
    final db = await database;
    final result = await db.update(
      'cadastro',
      {'texto': texto, 'numero': numero},
      where: 'id = ?',
      whereArgs: [id],
    );

    await _logOperacao('Update');
    return result;
  }

  Future<int> deleteCadastro(int numero) async {
    final db = await database;
    final cadastro = await getCadastroByNumero(numero);
    if (cadastro == null) return 0;

    final result = await db.delete(
      'cadastro',
      where: 'numero = ?',
      whereArgs: [numero],
    );

    await _logOperacao('Delete');
    return result;
  }

  Future<void> _logOperacao(String operacao) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.insert('log_operacoes', {
      'operacao': operacao,
      'data_hora': now,
    });
  }

  Future<Map<String, dynamic>?> getCadastroByNumero(int numero) async {
    final db = await database;
    final results = await db.query(
      'cadastro',
      where: 'numero = ?',
      whereArgs: [numero],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}