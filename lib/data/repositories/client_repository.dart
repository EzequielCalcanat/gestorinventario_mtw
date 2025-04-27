import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:flutterinventory/data/database/database_helper.dart';

class ClientRepository {
  static final Repository<Client> _repository = Repository<Client>(
    table: 'clients',
    fromMap: (map) => Client.fromMap(map),
    toMap: (branch) => branch.toMap(),
    moduleName: "Cliente"
  );

  static Future<List<Client>> getAllClients({int? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<int> insertClient(Client client) async {
    return await _repository.insert(client);
  }

  static Future<int> updateClient(Client client) async {
    return await _repository.update(client, client.id);
  }

  static Future<int> deleteClient(Client client) async {
    return await _repository.delete(client, client.id);
  }

  static Future<List<Client>> getClientsBetweenDates(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'clients',
      where: 'created_at BETWEEN ? AND ? AND is_active = 1',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String()
      ],
    );

    return result.map((map) => Client.fromMap(map)).toList();
  }

  static Future<Map<String, double>> getSalesByClientBetweenDates(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
    SELECT c.name as client_name, SUM(s.total) as total_sales
    FROM sales s
    JOIN clients c ON s.client_id = c.id
    WHERE s.date BETWEEN ? AND ? AND s.is_active = 1
    GROUP BY s.client_id
  ''', [start.toIso8601String(), end.toIso8601String()]);

    Map<String, double> salesByClient = {};

    for (var row in result) {
      salesByClient[row['client_name'] as String] = (row['total_sales'] as num?)?.toDouble() ?? 0.0;
    }

    return salesByClient;
  }

}