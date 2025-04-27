import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:flutterinventory/data/database/database_helper.dart';

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
    final result = await db.rawQuery('SELECT MAX(sale_number) as last_number FROM sales');

    if (result.isNotEmpty && result.first['last_number'] != null) {
      return (result.first['last_number'] as int);
    }
    return 0;
  }

  static Future<Map<String, double>> getSalesOfLast7Days() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 6));

    final result = await db.rawQuery('''
    SELECT 
      DATE(date) as sale_date,
      SUM(total) as total_sales
    FROM sales
    WHERE date BETWEEN ? AND ? AND is_active = 1
    GROUP BY DATE(date)
    ORDER BY sale_date ASC
  ''', [sevenDaysAgo.toIso8601String(), now.toIso8601String()]);

    Map<String, double> salesByDate = {};

    for (var row in result) {
      salesByDate[row['sale_date'] as String] = (row['total_sales'] as num?)?.toDouble() ?? 0.0;
      print( (row['total_sales'] as num?)?.toDouble());
    }

    for (int i = 0; i < 7; i++) {
      final date = sevenDaysAgo.add(Duration(days: i));
      final dateKey = "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";

      salesByDate.putIfAbsent(dateKey, () => 0.0);
    }
    final sortedKeys = salesByDate.keys.toList()..sort();
    final sortedMap = {for (var k in sortedKeys) k: salesByDate[k]!};

    return sortedMap;
  }

  static Future<List<Sale>> getSalesBetweenDates(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'sales',
      where: 'date BETWEEN ? AND ? AND is_active = 1',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String()
      ],
    );

    return result.map((map) => Sale.fromMap(map)).toList();
  }


  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
