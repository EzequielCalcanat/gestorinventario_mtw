import 'package:flutterinventory/data/models/branch.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

import '../database/database_helper.dart';

class BranchRepository {
  static final Repository<Branch> _repository = Repository<Branch>(
    table: 'branches',
    fromMap: (map) => Branch.fromMap(map),
    toMap: (branch) => branch.toMap(),
    moduleName: "Sucursal"
  );

  static Future<List<Branch>> getAllBranches({int? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<String> getBranchName(String branchId) async {
    List<Map<String, dynamic>> filters = [
      {'name': 'id', 'operator': '==', 'value': branchId},
      {'name': 'is_active', 'operator': '==', 'value': true}
    ];

    List<Branch> filteredBranches = await _repository.getFiltered(filters);

    if (filteredBranches.isNotEmpty) {
      return filteredBranches.first.name ?? 'Sucursal desconocida';
    } else {
      return 'Sucursal no encontrada';
    }
  }

  static Future<int> insertBranch(Branch branch) async {
    return await _repository.insert(branch);
  }

  static Future<int> updateBranch(Branch branch) async {
    return await _repository.update(branch, branch.id);
  }

  static Future<int> deleteBranch(Branch branch) async {
    return await _repository.delete(branch, branch.id);
  }
  static Future<List<Branch>> getBranchesBetweenDates(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'branches',
      where: 'created_at BETWEEN ? AND ? AND is_active = 1',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String()
      ],
    );

    return result.map((map) => Branch.fromMap(map)).toList();
  }

  static Future<Map<String, double>> getSalesByBranchBetweenDates(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
    SELECT b.name as branch_name, SUM(s.total) as total_sales
    FROM sales s
    JOIN branches b ON s.branch_id = b.id
    WHERE s.date BETWEEN ? AND ? AND s.is_active = 1
    GROUP BY s.branch_id
  ''', [start.toIso8601String(), end.toIso8601String()]);

    Map<String, double> salesByBranch = {};

    for (var row in result) {
      salesByBranch[row['branch_name'] as String] = (row['total_sales'] as num?)?.toDouble() ?? 0.0;
    }

    return salesByBranch;
  }


}
