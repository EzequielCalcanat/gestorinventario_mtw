import 'package:flutterinventory/data/database/database_helper.dart';
import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/models/log.dart';
import 'package:flutterinventory/data/models/payment_method.dart';
import 'package:flutterinventory/data/models/product.dart';
import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/models/sale_detail.dart';
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

  Future<List<T>> getFiltered(List<Map<String, dynamic>> filters) async {
    final db = await DatabaseHelper.instance.database;

    // Construir la cláusula WHERE de forma dinámica
    String whereClause = '';
    List<dynamic> whereArgs = [];

    for (var filter in filters) {
      String fieldName = filter['name'];
      String operator = filter['operator'];
      dynamic value = filter['value'];

      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }

      if (value is String) {
        whereClause += "$fieldName $operator ?";
        whereArgs.add(value);
      } else if (value is bool) {
        whereClause += "$fieldName $operator ?";
        whereArgs.add(value ? 1 : 0); // A enteros porque luego no funciona jeje
      } else {
        whereClause += "$fieldName $operator ?";
        whereArgs.add(value);
      }
    }

    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  Future<int> insert(T item) async {
    final map = toMap(item);
    final db = await DatabaseHelper.instance.database;
    final result = await db.insert(table, map);

    if (item is! SaleDetail || item is! PaymentMethod) {
      final logDescription = _getLogDescription(item, "save");
      await _createLog("save", logDescription);
    }
    return result;
  }

  Future<List<T>> getAll({int? isActive}) async {
    final db = await DatabaseHelper.instance.database;
    if (isActive == null) {
      final List<Map<String, dynamic>> maps = await db.query(table);
      return List.generate(maps.length, (i) => fromMap(maps[i]));
    } else {
      final List<Map<String, dynamic>> maps = await db.query(
        table,
        where: 'is_active = ?',
        whereArgs: [isActive],
      );
      return List.generate(maps.length, (i) => fromMap(maps[i]));
    }
  }

  Future<int> update(T item, String id) async {
    final map = toMap(item);
    map.removeWhere(
      (key, value) =>
          (key == 'isActive' || key == 'created_at' || key == 'updated_at') &&
          value == null,
    );

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

  Future<int> delete(T item, String id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.update(
      table,
      {'is_active': false},
      where: 'id = ?',
      whereArgs: [id],
    );

    final logDescription = _getLogDescription(item, "save");
    await _createLog("delete", logDescription);
    return result;
  }

  // Método para obtener una descripción de log
  String _getLogDescription(T item, String action) {
    if (item is Branch) {
      return (action == 'save' || action == 'update')
          ? (item as Branch).name
          : 'Sucursal: ${(item as Branch).id}';
    } else if (item is Client) {
      return (action == 'save' || action == 'update')
          ? (item as Client).name
          : 'Cliente: ${(item as Client).id}';
    } else if (item is Product) {
      return (action == 'save' || action == 'update')
          ? (item as Product).name
          : 'Producto: ${(item as Product).id}';
    } else if (item is User) {
      return (action == 'save' || action == 'update')
          ? (item as User).name
          : 'Usuario: ${(item as User).id}';
    } else if (item is Sale) {
      return (action == 'save')
          ? 'Venta #${(item as Sale).saleNumber}'
          : 'Venta: ${(item as Sale).id}';
    }

    return item.toString();
  }
}
