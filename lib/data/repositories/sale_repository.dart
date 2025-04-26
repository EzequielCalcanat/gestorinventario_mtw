import 'package:flutterinventory/data/models/sale.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

import '../database/database_helper.dart';

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
}
