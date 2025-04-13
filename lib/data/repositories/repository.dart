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
    final map = toMap(item);
    map.removeWhere((key, value) =>
    (key == 'created_at' || key == 'updated_at') && value == null);
    print(map);  // Para depurar
    final db = await DatabaseHelper.instance.database;
    return await db.insert(table, map);
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

    // Eliminar 'isActive' y 'created_at' si son null
    map.removeWhere((key, value) =>
    (key == 'isActive' || key == 'created_at') && value == null);

    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para eliminar un elemento (lógicamente, cambiando is_active a false)
  Future<int> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      {'is_active': false},  // Marcamos como eliminado
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

