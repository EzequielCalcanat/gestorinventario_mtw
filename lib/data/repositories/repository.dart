import 'package:flutterinventory/data/database/database_helper.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/models/log.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/repositories/log_repository.dart';
import 'package:uuid/uuid.dart';

class Repository<T> {
  final String table;
  final String moduleName;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;
  final LogRepository _logRepository = LogRepository();

  Repository({
    required this.table,
    required this.fromMap,
    required this.toMap,
    required this.moduleName,
  });

  Future<void> _createLog(String action, String description) async {
    final userId = await _logRepository.getLoggedUserId();
    final userName = await _logRepository.getLoggedUserName();
    if (userId == null || userName == null) return;

    final log = Log(
      id: const Uuid().v4(),
      action: action,
      module: moduleName,
      description: description,
      userId: userId,
      userName: userName,
      createdAt: null,
    );

    await _logRepository.insertLog(log);
  }

  String _getLogDescription(T item, String action) {
    if (item is Branch) {
      return (action == 'save' || action == 'update') ? (item as Branch).name : 'Sucursal: ${(item as Branch).id}';
    } else if (item is Client) {
      return (action == 'save' || action == 'update') ? (item as Client).name : 'Cliente: ${(item as Client).id}';
    } else if (item is Product) {
      return (action == 'save' || action == 'update') ? (item as Product).name : 'Producto: ${(item as Product).id}';
    } else if (item is User) {
      return (action == 'save' || action == 'update') ? (item as User).name : 'Usuario: ${(item as User).id}';
    } else if (item is Sale) {
      return (action == 'save') ? 'Venta #${(item as Sale).saleNumber}' : 'Venta: ${(item as Sale).id}';
    }

    // En caso de que el tipo no se reconozca, devolvemos algo genérico
    return item.toString();
  }

  // Método para insertar un elemento
  Future<int> insert(T item) async {
    final map = toMap(item);
    final db = await DatabaseHelper.instance.database;
    final result = await db.insert(table, map);

    final logDescription = _getLogDescription(item, "save");
    await _createLog("save", logDescription);
    return result;
  }

  // Método para obtener todos los elementos con o sin el filtro is_active
  Future<List<T>> getAll({bool? isActive}) async {
    final db = await DatabaseHelper.instance.database;

    // Si isActive es nulo, obtenemos todos los registros (sin filtro)
    if (isActive == null) {
      final List<Map<String, dynamic>> maps = await db.query(table);
      return List.generate(maps.length, (i) => fromMap(maps[i]));
    } else {
      // Si isActive es proporcionado, filtramos por is_active
      final List<Map<String, dynamic>> maps = await db.query(
        table,
        where: 'is_active = ?',
        whereArgs: [isActive],
      );
      return List.generate(maps.length, (i) => fromMap(maps[i]));
    }
  }

  // Método para actualizar un elemento
  Future<int> update(T item, String id) async {
    final map = toMap(item);

    // Eliminar campos nulos irrelevantes
    map.removeWhere((key, value) =>
    (key == 'isActive' || key == 'created_at' || key == 'updated_at') &&
        value == null);

    final db = await DatabaseHelper.instance.database;
    final result = await db.update(
      table,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );

    final logDescription = _getLogDescription(item, "update");
    await _createLog("update", logDescription);

    return result;
  }

  // Método para eliminar un elemento (lógicamente, cambiando is_active a false)
  Future<int> delete(T item, String id) async {
    final map = toMap(item);

    final db = await DatabaseHelper.instance.database;
    final result = await db.update(table, {'is_active': false}, where: 'id = ?', whereArgs: [id]);

    final logDescription = _getLogDescription(item, "save");
    await _createLog("delete", logDescription);
    return result;
  }
}

