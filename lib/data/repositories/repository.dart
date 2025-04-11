import 'package:flutterinventory/data/database/database_helper.dart';

class Repository<T> {
  final String table;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;

  Repository({
    required this.table,
    required this.fromMap,
    required this.toMap,
  });

  // Método para insertar un elemento
  Future<int> insert(T item) async {
    print(toMap(item));
    final db = await DatabaseHelper.instance.database;  // Asegúrate de que esto funcione
    return await db.insert(table, toMap(item));
  }

  // Método para obtener todos los elementos
  Future<List<T>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Método para actualizar un elemento
  Future<int> update(T item, String id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      toMap(item),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para eliminar un elemento
  Future<int> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
