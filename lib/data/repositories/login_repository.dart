import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterinventory/data/database/database_helper.dart';
import 'branch_repository.dart';

class LoginRepository {
  static final Repository<User> _repository = Repository<User>(
    table: 'users',
    fromMap: (map) => User.fromMap(map),
    toMap: (user) => user.toMap(),
    moduleName: "Usuario",
  );

  static Future<List<User>> getAllUsers({int? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<int> insertUser(User user) async {
    return await _repository.insert(user);
  }

  static Future<User?> login(String name, String password) async {
    final users = await getAllUsers(isActive: 1);
    try {
      return users.firstWhere((u) => u.name == name && u.password == password);
    } catch (e) {
      return null;
    }
  }

  static Future<int> updateUser(User user) async {
    return await _repository.update(user, user.id);
  }

  static Future<int> deleteUser(User user) async {
    return await _repository.delete(user, user.id);
  }

  static Future<void> updateUserBranchId(String branchId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_branch_id', branchId);
    final userId = prefs.getString('logged_user_id');

    if (userId != null) {
      final users = await getAllUsers();
      final user = users.firstWhere(
        (u) => u.id == userId,
        orElse: () {
          throw Exception('Usuario no encontrado');
        },
      );
      user.branchId = branchId;
      await updateUser(user);

      String branchName = await BranchRepository.getBranchName(
        user.branchId ?? "all",
      );
      await prefs.setString(
        'user_branch_name',
        branchName ?? 'Sucursal no encontrada',
      );
    } else {
      throw Exception('No se encontró el userId en SharedPreferences');
    }
  }

  static Future<List<Map<String, dynamic>>> getTopSellingUsers(
    DateTime start,
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
    SELECT 
      u.name as user_name, 
      b.name as branch_name, 
      IFNULL(COUNT(s.id), 0) as total_sales_count, 
      IFNULL(SUM(s.total), 0) as total_sales_amount
    FROM users u
    JOIN branches b ON u.branch_id = b.id
    LEFT JOIN sales s ON s.user_id = u.id AND s.date BETWEEN ? AND ? AND s.is_active = 1
    WHERE u.is_active = 1
    GROUP BY u.id
    ORDER BY total_sales_amount DESC
  ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    return result;
  }
}
