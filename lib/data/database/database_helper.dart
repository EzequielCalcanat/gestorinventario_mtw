import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/models/log.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/models/sale_detail.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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
      await db.execute('DROP TABLE IF EXISTS sale_details');
      await db.execute('DROP TABLE IF EXISTS sales');
      await db.execute('DROP TABLE IF EXISTS client');
      await db.execute('DROP TABLE IF EXISTS products');
      await db.execute('DROP TABLE IF EXISTS branches');
      await db.execute('DROP TABLE IF EXISTS logs');
      await db.execute('DROP TABLE IF EXISTS users');
      await _createDB(db, newVersion);
    }
  }

  // Crear las tablas
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE branches (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      location TEXT,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    ''');

    await db.execute('''
    CREATE TABLE clients (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      phone TEXT,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    ''');

    await db.execute('''
    CREATE TABLE products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      price REAL NOT NULL CHECK (price >= 0),
      stock INTEGER NOT NULL CHECK (stock >= 0),
      branch_id TEXT NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(branch_id) REFERENCES branches(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL,
      branch_id TEXT NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(branch_id) REFERENCES branches(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE payment_methods (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    ''');

    await db.execute('''
    CREATE TABLE sales (
      id TEXT PRIMARY KEY,
      sale_number INTEGER AUTO INCREMENT,
      date DATETIME DEFAULT CURRENT_TIMESTAMP,
      total REAL NOT NULL,
      branch_id TEXT NOT NULL,
      client_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      payment_method_id TEXT NOT NULL,
      FOREIGN KEY(branch_id) REFERENCES branches(id),
      FOREIGN KEY(client_id) REFERENCES clients(id),
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(payment_method_id) REFERENCES payment_methods(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE sale_details (
      id TEXT PRIMARY KEY,
      price REAL NOT NULL CHECK (price >= 0),
      quantity INTEGER NOT NULL CHECK (quantity >= 0),
      product_id TEXT NOT NULL,
      sale_id TEXT NOT NULL,
      FOREIGN KEY(product_id) REFERENCES products(id),
      FOREIGN KEY(sale_id) REFERENCES sales(id)
    );
    ''');

    await db.execute('''
    CREATE TABLE logs (
      id TEXT PRIMARY KEY,
      action TEXT NOT NULL,
      module TEXT NOT NULL,
      description TEXT,
      user_name TEXT NOT NULL,
      user_id TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES users(id)
    );
    ''');

    // Registros de prueba
    String branchId = await insertBranchExample(db);
    await insertUsers(db, branchId);
    await insertTestBranches(db);
    await insertTestProducts(db, branchId);
    await insertTestClients(db);
  }

  Future<String> insertBranchExample(Database db) async {
    const uuid = Uuid();
    String branchId = uuid.v4();
    await db.insert('branches', {
      'id': branchId,
      'name': 'Sucursal Central',
      'location': 'Blvd. Campestre #332',
    });
    return branchId;
  }

  Future<void> insertUsers(Database db, String branchId) async {
    const uuid = Uuid();
    // Usuario administrador
    String adminId = uuid.v4();
    await db.insert('users', {
      'id': adminId,
      'name': 'Administrador',
      'email': 'admin@gmail.com',
      'password': 'hola123',
      'role': 'admin',
      'branch_id': branchId,
    });
    // Usuario empleado
    String employeeId = uuid.v4();
    await db.insert('users', {
      'id': employeeId,
      'name': 'Juan Pérez',
      'email': 'empleado@gmail.com',
      'password': 'empleado123',
      'role': 'employee',
      'branch_id': branchId,
    });
    // Usuario de ventas
    String salesId = uuid.v4();
    await db.insert('users', {
      'id': salesId,
      'name': 'María Hdz',
      'email': 'ventas@gmail.com',
      'password': 'ventas123',
      'role': 'sales',
      'branch_id': branchId,
    });
  }

  final _uuid = Uuid();

  Future<List<String>> insertTestBranches(Database db) async {
    List<String> branchIds = [];
    final branches = [
      {'name': 'Sucursal Centro', 'location': 'Av. Principal 123'},
      {'name': 'Sucursal Norte', 'location': 'Calle Norte 456'},
      {'name': 'Sucursal Sur', 'location': 'Boulevard Sur 789'},
      {'name': 'Sucursal Este', 'location': 'Av. del Este 1011'},
      {'name': 'Sucursal Oeste', 'location': 'Calle del Oeste 1213'},
    ];
    for (var branch in branches) {
      final id = _uuid.v4();
      await db.insert('branches', {
        'id': id,
        'name': branch['name'],
        'location': branch['location'],
        'is_active': 1,
      });
      branchIds.add(id);
    }
    return branchIds;
  }

  Future<void> insertTestProducts(Database db, String branchId) async {
    final products = [
      {
        'name': 'Papas Sabritas',
        'description': 'Papas fritas clásicas',
        'price': 18.0,
        'stock': 50,
      },
      {
        'name': 'Doritos Nacho',
        'description': 'Botana de maíz con queso',
        'price': 20.0,
        'stock': 45,
      },
      {
        'name': 'Churrumais',
        'description': 'Botana de harina de maíz',
        'price': 12.0,
        'stock': 60,
      },
      {
        'name': 'Galletas Oreo',
        'description': 'Galletas de chocolate',
        'price': 16.0,
        'stock': 40,
      },
      {
        'name': 'Coca-Cola 600ml',
        'description': 'Refresco de cola',
        'price': 22.0,
        'stock': 70,
      },
      {
        'name': 'Chocolate Hershey\'s',
        'description': 'Barra de chocolate con leche',
        'price': 25.0,
        'stock': 35,
      },
      {
        'name': 'Panditas Ricolino',
        'description': 'Gomitas de sabores',
        'price': 14.0,
        'stock': 55,
      },
      {
        'name': 'Galletas Emperador',
        'description': 'Galletas rellenas',
        'price': 17.0,
        'stock': 30,
      },
      {
        'name': 'Gatorade 500ml',
        'description': 'Bebida hidratante',
        'price': 28.0,
        'stock': 25,
      },
      {
        'name': 'Takis Fuego',
        'description': 'Botana de maíz muy picante',
        'price': 21.0,
        'stock': 38,
      },
    ];

    for (var product in products) {
      final id = _uuid.v4();
      await db.insert('products', {
        'id': id,
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'stock': product['stock'],
        'branch_id': branchId,
        'is_active': 1,
      });
    }
  }

  Future<void> insertTestClients(Database db) async {
    final clients = [
      {
        'name': 'Carlos Martínez',
        'email': 'carlos@example.com',
        'phone': '5551234567',
      },
      {'name': 'Ana López', 'email': 'ana@example.com', 'phone': '5559876543'},
      {
        'name': 'Luis Hernández',
        'email': 'luis@example.com',
        'phone': '5557890123',
      },
      {
        'name': 'Laura García',
        'email': 'laura@example.com',
        'phone': '5554567890',
      },
      {
        'name': 'Pedro Sánchez',
        'email': 'pedro@example.com',
        'phone': '5553210987',
      },
      {
        'name': 'María Fernández',
        'email': 'maria@example.com',
        'phone': '5556543210',
      },
      {
        'name': 'José Ramírez',
        'email': 'jose@example.com',
        'phone': '5555678901',
      },
      {
        'name': 'Sofía Torres',
        'email': 'sofia@example.com',
        'phone': '5556789012',
      },
      {
        'name': 'Miguel Díaz',
        'email': 'miguel@example.com',
        'phone': '5557891234',
      },
      {
        'name': 'Paola Cruz',
        'email': 'paola@example.com',
        'phone': '5558901234',
      },
    ];
    for (var client in clients) {
      final id = _uuid.v4();
      await db.insert('clients', {
        'id': id,
        'name': client['name'],
        'email': client['email'],
        'phone': client['phone'],
        'is_active': 1,
      });
    }
  }

  // Insertar datos en cualquier tabla
  Future<int> insert<T>(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  // Eliminar datos lógicamente
  Future<int> delete<T>(String table, int id) async {
    final db = await database;
    return await db.update(
      table,
      {'is_active': false},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insertar una entidad genérica
  Future<int> insertEntity<T>(String table, T entity) async {
    final db = await database;
    final entityMap = _entityToMap(entity);
    return await db.insert(
      table,
      entityMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Consultar entidades genéricas
  Future<List<T>> getEntities<T>(
    String table,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    final db = await database;
    final result = await db.query(
      table,
      where: 'is_active = ?',
      whereArgs: [true],
    );
    return result.map((json) => fromMap(json)).toList();
  }

  // Convertir un objeto a un mapa
  Map<String, dynamic> _entityToMap<T>(T entity) {
    if (entity is Branch) {
      return (entity as Branch).toMap();
    } else if (entity is Client) {
      return (entity as Client).toMap();
    } else if (entity is Product) {
      return (entity as Product).toMap();
    } else if (entity is User) {
      return entity.toMap();
    } else if (entity is Sale) {
      return (entity as Sale).toMap();
    } else if (entity is SaleDetail) {
      return (entity as SaleDetail).toMap();
    } else if (entity is Log) {
      return (entity as Log).toMap();
    }
    throw ArgumentError('Tipo no soportado');
  }

  // Convertir un mapa a un objeto
  T _mapToEntity<T>(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    return fromMap(map);
  }
}
