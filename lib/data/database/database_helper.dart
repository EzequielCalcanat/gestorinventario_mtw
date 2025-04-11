import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/models/product.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aecn_inventory.db');
    return _database!;
  }

  // Inicialización de la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await db.execute('DROP TABLE IF EXISTS products');
      await db.execute('DROP TABLE IF EXISTS branches');
      await _createDB(db, newVersion);
    }
  }

  // Crear las tablas
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE branches (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      location TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      price REAL NOT NULL,
      stock INTEGER NOT NULL,
      branch_id TEST NOT NULL,
      FOREIGN KEY(branch_id) REFERENCES branches(id)
    );
  ''');
  }


  // Insertar datos en cualquier tabla
  Future<int> insert<T>(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Consultar datos de cualquier tabla
  Future<List<Map<String, dynamic>>> query<T>(String table) async {
    final db = await database;
    return await db.query(table);
  }

  // Actualizar datos de cualquier tabla
  Future<int> update<T>(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  // Eliminar datos de cualquier tabla
  Future<int> delete<T>(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // Insertar una entidad genérica (por ejemplo, una rama o producto)
  Future<int> insertEntity<T>(String table, T entity) async {
    final db = await database;
    // Usamos un método para convertir el objeto a un mapa
    final entityMap = _entityToMap(entity);
    return await db.insert(table, entityMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Consultar entidades genéricas
  Future<List<T>> getEntities<T>(String table, T Function(Map<String, dynamic>) fromMap) async {
    final db = await database;
    final result = await db.query(table);
    return result.map((json) => fromMap(json)).toList();
  }

  // Convertir un objeto a un mapa (por ejemplo, un producto o una rama)
  Map<String, dynamic> _entityToMap<T>(T entity) {
    if (entity is Branch) {
      return (entity as Branch).toMap();
    } else if (entity is Product) {
      return (entity as Product).toMap();
    }
    throw ArgumentError('Tipo no soportado');
  }

  // Convertir un mapa a un objeto (por ejemplo, un producto o una rama)
  T _mapToEntity<T>(Map<String, dynamic> map, T Function(Map<String, dynamic>) fromMap) {
    return fromMap(map);
  }
}
