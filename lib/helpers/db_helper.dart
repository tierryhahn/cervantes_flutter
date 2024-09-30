import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter assíncrono para recuperar a instância do banco de dados, inicializando-o se necessário
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Método para obter todos os registros da tabela 'cadastro'
  Future<List<Map<String, dynamic>>> getAllCadastros() async {
    final db = await database;
    return await db.query('cadastro');
  }

  // Método privado para inicializar o banco de dados
  Future<Database> _initDb() async {
    sqfliteFfiInit(); // Inicialização do driver FFI para banco de dados
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cadastro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Criação da tabela 'cadastro'
        await db.execute('''
          CREATE TABLE cadastro (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            texto TEXT NOT NULL,
            numero INTEGER NOT NULL UNIQUE CHECK(numero > 0)
          );
        ''');

        // Criação da tabela 'log_operacoes' para registrar operações de insert, update e delete
        await db.execute('''
          CREATE TABLE log_operacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operacao TEXT NOT NULL,
            data_hora TEXT NOT NULL
          );
        ''');

        // Trigger para log operação de inserção
        await db.execute('''
          CREATE TRIGGER trg_after_insert
          AFTER INSERT ON cadastro
          BEGIN
            INSERT INTO log_operacoes (operacao, data_hora)
            VALUES ('Insert', DATETIME('now'));
          END;
        ''');

        // Trigger para log operação de atualização
        await db.execute('''
          CREATE TRIGGER trg_after_update
          AFTER UPDATE ON cadastro
          BEGIN
            INSERT INTO log_operacoes (operacao, data_hora)
            VALUES ('Update', DATETIME('now'));
          END;
        ''');

        // Trigger para log operação de exclusão
        await db.execute('''
          CREATE TRIGGER trg_after_delete
          AFTER DELETE ON cadastro
          BEGIN
            INSERT INTO log_operacoes (operacao, data_hora)
            VALUES ('Delete', DATETIME('now'));
          END;
        ''');
      },
    );
  }

  // Método para inserir um registro na tabela 'cadastro'
  Future<int> insertCadastro(String texto, int numero) async {
    final db = await database;
    final result = await db.insert('cadastro', {
      'texto': texto,
      'numero': numero,
    });
    return result;
  }

  // Método para atualizar um registro na tabela 'cadastro'
  Future<int> updateCadastro(int id, String texto, int numero) async {
    final db = await database;
    final result = await db.update(
      'cadastro',
      {'texto': texto, 'numero': numero},
      where: 'id = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Método para deletar um registro na tabela 'cadastro' com base no número fornecido
  Future<int> deleteCadastro(int numero) async {
    final db = await database;
    final cadastro = await getCadastroByNumero(numero);
    if (cadastro == null) return 0;

    // Deleta o registro e retorna o número de linhas afetadas
    final result = await db.delete(
      'cadastro',
      where: 'numero = ?',
      whereArgs: [numero],
    );
    return result;
  }

  // Método para obter um registro da tabela 'cadastro' com base no número fornecido
  Future<Map<String, dynamic>?> getCadastroByNumero(int numero) async {
    final db = await database;
    final results = await db.query(
      'cadastro',
      where: 'numero = ?',
      whereArgs: [numero],
    );

    // Retorna o primeiro resultado se houver, senão retorna null
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}