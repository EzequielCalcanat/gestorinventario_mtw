import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/models/sale_item.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:flutterinventory/data/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaleRepository extends Repository<Sale> {
  SaleRepository()
    : super(
        table: 'sales',
        moduleName: 'Ventas',
        fromMap: (map) => Sale.fromMap(map),
        toMap: (sale) => sale.toMap(),
      );

  static Future<int> getLastSaleNumber() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT MAX(sale_number) as last_number FROM sales',
    );

    if (result.isNotEmpty && result.first['last_number'] != null) {
      return (result.first['last_number'] as int);
    }
    return 0;
  }

  static Future<Map<String, double>> getSalesOfLast7Days() async {
    final db = await DatabaseHelper.instance.database;
    final prefs = await SharedPreferences.getInstance();
    final userBranchId = prefs.getString('user_branch_id');

    if (userBranchId == null) {
      // Opcional: podrías lanzar una excepción, o simplemente retornar todo 0
      return {};
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    final result = await db.rawQuery(
      '''
    SELECT 
      DATE(date) as sale_date,
      SUM(total) as total_sales
    FROM sales
    WHERE date BETWEEN ? AND ? 
      AND is_active = 1
      AND branch_id = ?
    GROUP BY DATE(date)
    ORDER BY sale_date ASC
    ''',
      [
        sevenDaysAgo.toIso8601String(),
        now.toIso8601String(),
        userBranchId,
      ],
    );

    Map<String, double> salesByDate = {};

    for (var row in result) {
      salesByDate[row['sale_date'] as String] =
          (row['total_sales'] as num?)?.toDouble() ?? 0.0;
    }

    for (int i = 0; i < 7; i++) {
      final date = sevenDaysAgo.add(Duration(days: i));
      final dateKey =
          "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";

      salesByDate.putIfAbsent(dateKey, () => 0.0);
    }

    final sortedKeys = salesByDate.keys.toList()..sort();
    final sortedMap = {for (var k in sortedKeys) k: salesByDate[k]!};

    return sortedMap;
  }

  static Future<List<Sale>> getSalesBetweenDates(
    DateTime start,
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'sales',
      where: 'date BETWEEN ? AND ? AND is_active = 1',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return result.map((map) => Sale.fromMap(map)).toList();
  }

  static Future<List<SaleItem>> getSalesHistory() async {
    final db = await DatabaseHelper.instance.database;

    final prefs = await SharedPreferences.getInstance();
    final userBranchId = prefs.getString('user_branch_id');

    if (userBranchId == null) {
      // Opcionalmente podrías manejar error aquí si no existe la sucursal activa
      return [];
    }

    final result = await db.rawQuery('''
    SELECT 
      s.id,
      c.name as client_name,
      pm.name as payment_method_name,
      s.total,
      s.date,
      (SELECT SUM(quantity) FROM sale_details sd WHERE sd.sale_id = s.id) as total_products
    FROM sales s
    JOIN clients c ON s.client_id = c.id
    JOIN payment_methods pm ON s.payment_method_id = pm.id
    WHERE s.is_active = 1
      AND s.branch_id = ?
    ORDER BY s.date DESC
  ''', [userBranchId]);

    return result.map((map) {
      return SaleItem(
        id: map['id'] as String,
        clientName: map['client_name'] as String,
        paymentMethodName: map['payment_method_name'] as String,
        total: (map['total'] as num).toDouble(),
        totalProducts: (map['total_products'] as int?) ?? 0,
        date: map['date'] as String,
      );
    }).toList();
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
