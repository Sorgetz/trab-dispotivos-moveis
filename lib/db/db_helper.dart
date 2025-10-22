import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Instância única (singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Referência privada ao Database do sqflite
  static Database? _database;

  // Construtor privado
  DatabaseHelper._init();

  // Getter assíncrono para obter o Database (cria se necessário)
  Future<Database> get database async {
    // Se já inicializamos, retornamos a instância existente
    if (_database != null) return _database!;

    // Caso contrário, inicializamos o banco
    _database = await _initDB('clientesv3.db');
    return _database!;
  }

  // Inicializa o banco e retorna o Database
  Future<Database> _initDB(String fileName) async {
    // Pega o diretório de documentos da aplicação (onde o DB será salvo)
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // Monta o caminho completo até o arquivo do banco
    final dbPath = join(documentsDirectory.path, fileName);

    // Abre (ou cria) o banco de dados passando um onCreate que cria a tabela
    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  // SQL de criação das tabelas
  Future _createDB(Database db, int version) async {
    // Cria a tabela 'clientes' com as colunas solicitadas
    await db.execute('''
      CREATE TABLE clientes (
      codigo INTEGER PRIMARY KEY AUTOINCREMENT,
      cpf TEXT NOT NULL,
      nome TEXT NOT NULL,
      idade INTEGER NOT NULL,
      dataNascimento TEXT NOT NULL,
      cidadeNascimento TEXT NOT NULL
      );
''');

    await db.execute('''
      CREATE TABLE cidades (
      codigo INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      estado TEXT NOT NULL
      );
''');
  }

  // Fecha o banco (quando necessário)
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
