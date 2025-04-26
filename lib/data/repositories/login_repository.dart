import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'branch_repository.dart';

class LoginRepository {
  static final Repository<User> _repository = Repository<User>(
    table: 'users',
    fromMap: (map) => User.fromMap(map),
    toMap: (user) => user.toMap(),
    moduleName: "Usuario"
  );

  static Future<List<User>> getAllUsers({bool? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<int> insertUser(User user) async {
    return await _repository.insert(user);
  }

  static Future<User?> login(String name, String password) async {
    final users = await getAllUsers(isActive: true);
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
      final user = users.firstWhere((u) => u.id == userId, orElse: () {
        throw Exception('Usuario no encontrado');
      });
      user.branchId = branchId;
      await updateUser(user);

      String branchName = await BranchRepository.getBranchName(user.branchId ?? "all");
      await prefs.setString('user_branch_name', branchName ?? 'Sucursal no encontrada');
    } else {
      throw Exception('No se encontró el userId en SharedPreferences');
    }
  }
}
